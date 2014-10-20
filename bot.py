import settings

import sys
#sys.path.append(settings.core_path)

import os

from gevent import monkey; monkey.patch_all()
from gevent import spawn, spawn_later

from geweb import log
from point.util.queue import Queue
from point.util import proctitle
from point.util import cache_get, cache_store, cache_del
import json
import sleekxmpp
from sleekxmpp.xmlstream.jid import JID

class XMPPBot(sleekxmpp.ClientXMPP):
    def __init__(self):
        proctitle('bot')
        log.info('bot started with PID=%d' % os.getpid())

        self._jid = "%s/%s" % (settings.xmpp_jid, settings.xmpp_resource)
        sleekxmpp.ClientXMPP.__init__(self, self._jid, settings.xmpp_password)

        self.add_event_handler("session_start", self.start)
        self.add_event_handler("message", self.handle_message)
        self.add_event_handler("presence_subscribed", self.handle_subscription)

        self.xin = Queue('xin', addr=settings.queue_socket)
        self.xout = Queue('xout', addr=settings.queue_socket)

        self.auto_authorize = True
        self.auto_subscribe = True

        spawn(self.listen_queue)

    def start(self, event):
        self.send_presence()
        self.get_roster()

    def handle_subscription(self, presence):
        key = 'presence:%s:%s' % (presence['type'], presence['from'].bare)
        data = cache_get(key)
        if data:
            cache_del(key)
            self.send_message(**data)
            

    def handle_message(self, msg):
        if msg['type'] in ('chat', 'normal'):
            try:
                jid, resource = str(msg['to']).split('/', 1)
            except ValueError:
                jid = settings.xmpp_jid
                resource = settings.xmpp_resource
            self.xin.push(json.dumps({'from': str(msg['from']),
                                      'resource': resource,
                                      'body': msg['body'].strip()}))

    def listen_queue(self):
        try:
            data = self.xout.pop()
            if data:
                data = json.loads(data)
        except Exception, e:
            log.error('%s %s %s' % (e.__class__.__name__, e.message,
                                    type(data), data))
            data = None
        if not data:
            spawn_later(0.05, self.listen_queue)
            return

        try:
            html = None
            if 'html' in data and data['html']:
                html = sleekxmpp.xmlstream.ET.XML('<div style="margin-top:0">%s</div>' % data['html'])
                    #'<html xmlns="http://jabber.org/protocol/xhtml-im">' + \
                    #'<body xmlns="http://www.w3.org/1999/xhtml">%s</body></html>'
            if '_resource' in data and data['_resource']:
                mfrom = '%s/%s' % (settings.xmpp_jid, data['_resource'])
            else:
                mfrom = self._jid

            if self.check_subscription(data['to']):
                if '_presence' in data and data['_presence']:
                    pstatus = data['_presence'] \
                                if isinstance(data['_presence'], (str, unicode)) \
                                else "I'm online"
                    self.send_presence(pto=data['to'], pstatus=pstatus)

                self.send_message(mfrom=mfrom, mto=data['to'], mtype='chat',
                                  mbody=data['body'], mhtml=html)
            elif '_authorize' in data and data['_authorize']:
                # TODO: request subscription
                self.sendPresenceSubscription(pto=data['to'])
                cache_store('presence:subscribed:%s' % JID(data['to']).bare,
                            {'mfrom': mfrom, 'mto': data['to'], 'mtype': 'chat',
                             'mbody': data['body'], 'mhtml': html},
                            3600 * 24 * 7)
        finally:
            spawn(self.listen_queue)

    def check_subscription(self, jid):
        try:
            return self.roster[JID(jid).bare]['subscription'] == 'both'
        except KeyError:
            return False

if __name__ == '__main__':
    bot = XMPPBot()
    if bot.connect():
        bot.process(threaded=False)
