import settings

import sys
try:
    sys.path.extend(settings.libs)
except AttributeError:
    pass

from multiprocessing import Process

def run_bot():
    from bot import XMPPBot
    b = XMPPBot()
    if b.connect():
        b.process(threaded=False)

if __name__ == '__main__':
    from worker import XMPPWorker
    for i in xrange(settings.workers):
        p = Process(target=XMPPWorker)
        p.start()

    from sender import XMPPSender, XMPPSenderQueue
    for i in xrange(settings.senders):
        p = Process(target=XMPPSender)
        p.start()

    Process(target=XMPPSenderQueue).start()

    run_bot()

