-- Prosody XMPP Server Configuration
--
-- Information on configuring Prosody can be found on our
-- website at http://prosody.im/doc/configure
--
-- Tip: You can check that the syntax of this file is correct
-- when you have finished by running: luac -p prosody.cfg.lua
-- If there are any errors, it will let you know what and where
-- they are, otherwise it will keep quiet.
--

---------- Server-wide settings ----------
-- Settings in this section apply to the whole server and are the default settings
-- for any virtual hosts

-- This is a (by default, empty) list of accounts that are admins
-- for the server. Note that you must create the accounts separately
-- (see http://prosody.im/doc/creating_accounts for info)
-- Example: admins = { "user1@example.com", "user2@example.net" }
admins = {"arts@psto.net", "arts@point.im", "eoranged@psto.net" }

-- Enable use of libevent for better performance under high load
-- For more information see: http://prosody.im/doc/libevent
use_libevent = true;
--use_libevent = false;

-- dialback_secret = "jsahdkjashdkhsakjd8uijwikdsj873eruf78uewjhds";
-- This is the list of modules Prosody will load on startup.
-- It looks for mod_modulename.lua in the plugins folder, so make sure that exists too.
-- Documentation on modules can be found at: http://prosody.im/doc/modules
modules_enabled = {

	-- Generally required
		"roster"; -- Allow users to have a roster. Recommended ;)
		"saslauth"; -- Authentication for clients and servers. Recommended if you want to log in.
		"tls"; -- Add support for secure TLS on c2s/s2s connections
		"dialback"; -- s2s dialback support
		"disco"; -- Service discovery

	-- Not essential, but recommended
		"private"; -- Private XML storage (for room bookmarks, etc.)
		"vcard"; -- Allow users to set vCards
		--"privacy"; -- Support privacy lists
		--"compression"; -- Stream compression

	-- Nice to have
		"legacyauth"; -- Legacy authentication. Only used by some old clients and bots.
		-- "version"; -- Replies to server version requests
		-- "uptime"; -- Report how long server has been running
		-- "time"; -- Let others know the time here on this server
		"ping"; -- Replies to XMPP pings with pongs
		"pep"; -- Enables users to publish their mood, activity, playing music and more
		"register"; -- Allow users to register on this server using a client and change passwords
		"adhoc"; -- Support for "ad-hoc commands" that can be executed with an XMPP client

	-- Admin interfaces
		"admin_adhoc"; -- Allows administration via an XMPP client that supports ad-hoc commands
		"admin_telnet"; -- Opens telnet console interface on localhost port 5582

	-- Other specific functionality
		"posix"; -- POSIX functionality, sends server to background, enables syslog, etc.
		--"bosh"; -- Enable BOSH clients, aka "Jabber over HTTP"
		--"httpserver"; -- Serve static files from a directory over HTTP
		--"groups"; -- Shared roster support
		--"announce"; -- Send announcement to all online users
		--"welcome"; -- Welcome users who register accounts
		--"watchregistrations"; -- Alert admins of registrations
		--"motd"; -- Send a message to users when they log in

	-- Contrib modules
		"s2s_blackwhitelist"; -- http://code.google.com/p/prosody-modules/wiki/mod_s2s_blackwhitelist
		"s2s_auth_compat"; -- for ya.ru
};

-- These modules are auto-loaded, should you
-- (for some mad reason) want to disable
-- them then uncomment them below
modules_disabled = {
	-- "presence"; -- Route user/contact status information
	-- "message"; -- Route messages
	-- "iq"; -- Route info queries
	-- "offline"; -- Store offline messages
};

-- Disable account creation by default, for security
-- For more information see http://prosody.im/doc/creating_accounts
allow_registration = false;

-- These are the SSL/TLS-related settings. If you don't want
-- to use SSL/TLS, you may comment or remove this
--ssl = {
--	key = "/etc/prosody/certs/localhost.key";
--	certificate = "/etc/prosody/certs/localhost.cert";
--}

-- Only allow encrypted streams? Encryption is already used when
-- available. These options will cause Prosody to deny connections that
-- are not encrypted. Note that some servers do not support s2s
-- encryption or have it disabled, including gmail.com and Google Apps
-- domains.

--c2s_require_encryption = false
--s2s_require_encryption = false

-- s2s blacklisting
s2s_enable_blackwhitelist = "blacklist"
s2s_blacklist = { "gomorra.dyndns-remote.com" }

-- Select the authentication backend to use. The 'internal' providers
-- use Prosody's configured data storage to store the authentication data.
-- To allow Prosody to offer secure authentication mechanisms to clients, the
-- default provider stores passwords in plaintext. If you do not trust your
-- server please see http://prosody.im/doc/modules/mod_auth_internal_hashed
-- for information about using the hashed backend.

authentication = "internal_plain"

-- Select the storage backend to use. By default Prosody uses flat files
-- in its configured data directory, but it also supports more backends
-- through modules. An "sql" backend is included by default, but requires
-- additional dependencies. See http://prosody.im/doc/storage for more info.

--storage = "sql" -- Default is "internal"

-- For the "sql" backend, you can uncomment *one* of the below to configure:
--sql = { driver = "SQLite3", database = "prosody.sqlite" } -- Default. 'database' is the filename.
--sql = { driver = "MySQL", database = "prosody", username = "prosody", password = "KJHkjHjhKJDHud8wijijdc98ASIU", host = "localhost" }
--sql = { driver = "PostgreSQL", database = "prosody", username = "prosody", password = "KJHkjHjhKJDHud8wijijdc98ASIU", host = "localhost" }

-- Logging configuration
-- For advanced logging see http://prosody.im/doc/logging
-- Hint: If you create a new log file or rename them, don't forget 
-- to update the logrotate config at /etc/logrotate.d/prosody
log = {
        -- Log all error messages to prosody.err
        error = "/var/log/prosody/prosody.err";
	warn = "/var/log/prosody/prosody.warn";
	-- info = "/var/log/prosody/prosody.info";
        -- Log everything of level "info" and higher (that is, all except "debug" messages)
        -- to prosody.log
        debug = "/var/log/prosody/prosody.log"; -- Change 'info' to 'debug' for more verbose logging
        -- "*syslog"; -- Uncomment this for logging to syslog
}

-- Pidfile, used by prosodyctl and the init.d script
pidfile = "/var/run/prosody/prosody.pid";
daemonize = false;

----------- Virtual hosts -----------
-- You need to add a VirtualHost entry for each domain you wish Prosody to serve.
-- Settings under each VirtualHost entry apply *only* to that host.

-- VirtualHost "localhost"

VirtualHost "psto.net"

        ssl = {
                key = "/etc/prosody/certs/psto_net.key";
                certificate = "/etc/prosody/certs/psto_net.crt";
        }

VirtualHost "point.im"

        ssl = {
                key = "/home/point/settings/ssl/private.key";
                certificate = "/home/point/settings/ssl/server.crt";
        }


------ Components ------
-- You can specify components to add hosts that provide special services,
-- like multi-user conferences, and transports.
-- For more information on components, see http://prosody.im/doc/components

---Set up a MUC (multi-user chat) room server on conference.example.com:
--Component "conference.psto.net" "muc"
--Component "conference.point.im" "muc"
--   modules_enabled = {
--      "muc_log";
--   }

-- Set up a SOCKS5 bytestream proxy for server-proxied file transfers:
Component "proxy.psto.net" "proxy65"

---Set up an external component (default component port is 5347)
--
-- External components allow adding various services, such as gateways/
-- transports to other networks like ICQ, MSN and Yahoo. For more info
-- see: http://prosody.im/doc/components#adding_an_external_component
--
Component "icq.psto.net"
    component_secret = "s56d5tfuvgjkf75futvghdxwqsd7iujUHD65ydchgjyt76tygv"

