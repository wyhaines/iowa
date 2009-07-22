require 'iowa/Association'
require 'singleton'

module Iowa

	class UnknownValue
		include Singleton
		def to_s
			'UNK'
		end
	end
	alias :to_str :to_s

	BindingKeywords = {'action' => [LiteralAssociation,true],
		'id' => [LiteralAssociation, false],
		'item' => [PathAssociation,true],
		'list' => [PathAssociation,true],
		'key' => [PathAssociation,true],
		'klass' => [LiteralAssociation,true], # not 'class' because of HTML conflict
		'tag' => [LiteralAssociation,true],
		'condition' => [PathAssociation,true],
		'value' => [PathAssociation,true]}

	ClassSeparator = '::'.freeze
	ContentClassesNamespace = 'Iowa::Application::ContentClasses'.freeze

	C_empty = ''.freeze
	C_ = ' '.freeze
	C_anon_ = '_anon_'.freeze
	C_at = '@'.freeze
	C_atat = '@@'.freeze
	C_bnd = '.bnd'.freeze
	C_content = '_content'.freeze
	C_default = '_default'.freeze
	C_dot = '.'.freeze
	C_dotdot = '..'.freeze
	C_equal = '='.freeze
	C_gt = '>'.freeze
	C_item = '_item'.freeze
	C_iwa = '.iwa'.freeze
	C_list = '_list'.freeze
	C_method = '_method'.freeze
	C_semicolon = ';'.freeze
	C_slash = '/'.freeze
	C0 = '0'.freeze
	C_0to7 = 0..7.freeze
	C1 = '1'.freeze
	Caction = 'action'.freeze
	Caddresses = 'addresses'.freeze
	Capplication = 'application'.freeze
	Capplication_data = 'application/data'.freeze
	Cbasedir = 'basedir'.freeze
	Cbaselog = 'baselog'.freeze
	Cbasename = 'basename'.freeze
	Cbody = 'body'.freeze
	CBodyContent = 'BodyContent'.freeze
	Cbrowsers = 'browsers'.freeze
	Cbutton = 'button'.freeze
	Ccacheable = 'cacheable'.freeze
	Ccheckbox = 'checkbox'.freeze
	Cchecked = 'checked'.freeze
	Cchecksum = 'checksum'.freeze
	CClass = 'Class'.freeze
	Cclass = 'class'.freeze
	Ccondition = 'condition'.freeze
	CContentClasses = 'ContentClasses'.freeze
	CCookie = 'Cookie'.freeze
	Ccookie = 'cookie'.freeze
	Cdaemonize = 'daemonize'.freeze
	Cdatabase = 'database'.freeze
	Cdefault = 'default'.freeze
	Cdepth = 'depth'.freeze
	Cdirectory = 'directory'.freeze
	Cdispatcher = 'dispatcher'.freeze
	Cdoc_root = 'doc_root'.freeze
	Cdocroot = 'docroot'.freeze
	CdynamicString = 'dynamicString'.freeze
	Celement = 'element'.freeze
	Cexceptions = 'exceptions'.freeze
	Cfalse = 'false'.freeze
	CFALSE = 'false'.freeze
	Cfilename = 'filename'.freeze
	Cfiles = 'files'.freeze
	Cforce = 'force'.freeze
	CEIN = 'EIN'.freeze
	CHash = 'Hash'.freeze
	Cheight = 'height'.freeze
	Chostname = 'hostname'.freeze
	Chosts = 'hosts'.freeze
	Chref = 'href'.freeze
	Cid = 'id'.freeze
	Cimage = 'image'.freeze
	Cimage_path = 'image_path'.freeze
	Cinterval = 'interval'.freeze
	Ciowa_log = 'iowa_log'.freeze
	Ciowa_root = 'iowa_root'.freeze
	Cips = 'ips'.freeze
	Citem = 'item'.freeze
	Ckey = 'key'.freeze
	Cklass = 'klass'.freeze
	Clabel = 'label'.freeze
	Clast_modification = 'last_modification'.freeze
	Clibrary = 'library'.freeze
	Clink = 'link'.freeze
	Clist = 'list'.freeze
	CLocation = 'Location'.freeze
	Clog_root = 'log_root'.freeze
	Clogging = 'logging'.freeze
	Clonely_tag_terminator = ' />'.freeze
	CMain = 'Main'.freeze
	Cmapfile = 'mapfile'.freeze
	Cmaxage = 'maxage'.freeze
	Cmaxsize = 'maxsize'.freeze
	Cmethod = 'method'.freeze
	Cminlevel = 'minlevel'.freeze
	Cmodel = 'model'.freeze
	Cmultiple = 'multiple'.freeze
	Cname = 'name'.freeze
	COK = 'OK'.freeze
	Cpage = 'page'.freeze
	Cpagecache = 'pagecache'.freeze
	Cparams = 'params'.freeze
	Cpath = 'path'.freeze
	Cpolicy = 'policy'.freeze
	Cport = 'port'.freeze
	Cplural = 'plural'.freeze
	Cpost = 'post'.freeze
	Cradio = 'radio'.freeze
	Crefresh = 'refresh'.freeze
	Crequest_cacheable = 'request_cacheable'.freeze
	Croot_path = 'root_path'.freeze
	Croot_url = 'root_url'.freeze
	Cscreens = 'screens'.freeze
	Cselected = 'selected'.freeze
	Cserialize_templates = 'serialize_templates'.freeze
	Csession = 'session'.freeze
	Csessioncache = 'sessioncache'.freeze
	Csingular = 'singular'.freeze
	Csocket = 'socket'.freeze
	Csrc = 'src'.freeze
	Csubmit = 'submit'.freeze
	Ctagclass = 'tagclass'.freeze
	Ctag = 'tag'.freeze
	CtemplateRoot = 'templateRoot'.freeze
	Ctext_html = 'text/html'.freeze
	Ctext_javascript = 'text/javascript'.freeze
	Ctitle = 'title'.freeze
	Ctrue = 'true'.freeze
	CTRUE = 'TRUE'.freeze
	Cttl = 'ttl'.freeze
	Ctype = 'type'.freeze
	Cuse_lockfile = 'use_lockfile'.freeze
	CUserAgent = 'User-Agent'.freeze
	Cvalue = 'value'.freeze
	Cvariation = 'variation'.freeze
	Cwebrick = 'webrick'.freeze
	Cwidth = 'width'.freeze

end
