require 'tmail'
require 'net/smtp'
require 'forwardable'

module Iowa
	# A specialized component that lets one easily create and send customize
	# email.  An instance of Iowa::Email can send itself, or can return a text
	# representation suitable for piping into some other sending system.
	class Email < Component
		extend Forwardable
		def_delegators('@mail_obj','to','to=','from','from=','subject','subject=','date','date=','mime_version','mime_version=','content_type','content_type=','body','body=','cc','cc=','bcc','bcc=','reply_to','reply_to=','sender','sender=','message_id','message_id=','in_reply_to','in_reply_to=','references','references=','transfer_encoding','transfer_encoding=','disposition','disposition=')

		attr_accessor :has_mimetypes, :mail_obj, :smtp_account, :smtp_password, :smtp_connection, :attachments

		class Attachment < Hash
			def preamble
				r = ''
				if self[:attachment_type] == :as_content
					r << "Content-Type: #{self[:content_type]}\r\n"
					r << "Content-Transfer-Encoding: bit\r\n"
				else
					r << "Content-Type: #{self[:content_type]}; name=#{self[:filename]}\r\n"
					r << "Content-Transfer-Encoding: base64\r\n"
					r << "Content-Disposition: attachment; filename=#{self[:filename]}\r\n"
				end
				r
			end
		end

		def initialize(name, bindings, attributes, parent)
			super(name,bindings,attributes,parent)
			email_init
		end

		def unique_id
			t = Time.now
			[sprintf('%08x',Iowa.app.rand(2147483647)),
				sprintf('%02x',t.to_i),
				sprintf('%02x',t.usec),
				sprintf('%08x',Iowa.app.rand(2147483647))].join
		end

		def mime_boundary
			"iowa_mime_part_#{unique_id}"
		end

		def boundary
			@boundary ||= mime_boundary
			@boundary
		end

		def naive_mimetype_checker(fn)
			filename = File.basename(fn).downcase
			case filename
			when /\.jp(e?)g$/
				['image/jpg']
			when /\.gif$/
				['image/gif']
			when /\.htm?l$/
				['text/html']
			when /\.png$/
				['image/png']
			when /\.txt$/
				['text/plain']
			when /\.zip$/
				['application/zip']
			else
				['application/data']
			end
		end

		def check_mimetype(filename)
			if has_mimetypes?
				r = MIME::Types.type_for(filename)
			else
				r = naive_mimetype_checker(filename)
			end

			r.length > 0 ? r[0] : 'application/data'
		end

		def attach_file(file_or_handle, email_filename, attachment_type = nil)
			# Use MIME::Types to get the type for the filename
			# (use email_filename for this), if it is availble.
			# If it is not, then fallback to a naive internal
			# routine.
			unless has_mimetypes
				begin
					require 'mime/types'
					has_mimetypes = true
				rescue Exception
					has_mimetypes = false
				end
			end
			mimetype = check_mimetype(email_filename)
			fh = file_or_handle.kind_of?(File) ?
				file_or_handle : File.new(file_or_handle)
			unless attachment_type
				if /^text\//.match(mimetype)
					attachment_type = :as_content
				else
					attachment_type = :as_attachment
				end
			end
			attach_content(fh.readlines.join,mimetype,email_filename,attachment_type)
		end

		def attach_content(content, content_type, email_filename=nil, attachment_type=:as_attachment)
			# Attach the given content, with the given type.
			# It'd be cool if there were code that could guess
			# the MIME type based on the content itself, if a
			# type were not given.
			@boundary = mime_boundary unless @boundary
			unless @attachments
				@attachments = []
			end
			unless email_filename
				@attach_name_count ||= 0
				@attach_name_count += 1
				email_filename = "file_#{@attach_name_count}"
			end
			attachment = {
				:content_type => content_type,
				:filename => File.basename(email_filename),
				:content => content,
				:attachment_type => attachment_type}
		end
		
		def mime_preamble
			"\r\nThis is a multi-part message in MIME format.\r\n\r\n"
		end

		def email_init(params = {})
			@body_generated_flag = false
			@mail_obj = TMail::Mail.new unless mail_obj
			self.subject = " "
			self.content_type = 'text/plain' unless self.content_type
			if h = self.class.instance_variable_get('@additional_headers')
				h.each do |k,v|
					@mail_obj[k] = v
				end
			end
			[:smtp_server, :smtp_port, :helo_domain, :authentication, :smtp_account, :smtp_password, :recipients, :to, :from, :subject, :date, :sent_on, :mime_version, :content_type, :body, :cc, :bcc, :reply_to, :sender, :message_id, :in_reply_to, :references, :transfer_encoding, :disposition].each do |param|
				if p = self.class.instance_variable_get("@#{param}")
					self.__send__("#{param}=", p)
				end
				self.__send__("#{param}=", params[param])if params.has_key?(param)
				params.delete(param)
			end
			params.each {|k,v| self[k] = v}
		end
		
		remove_method(:body)
		def body
			generate_body unless body_generated?
			mail_obj.body
		end
		
		def preamble
			generate_body unless body_generated?
			mail_obj.preamble
		end
			
		def epilogue
			generate_body unless body_generated?
			mail_obj.epilogue
		end
				
		def multipart?
			generate_body unless body_generated?
			mail_obj.multipart?
		end
			
		def body_generated?
			@body_generated_flag
		end
		
		def recipients
			mail_obj.to
		end
		
		def recipients=(recip_list)
			mail_obj.to = recip_list
		end
		
		def smtp_server
			@smtp_server.nil? ? "smtp.#{Socket.gethostname}" : @smtp_server
		end
		
		def smtp_server=(server)
			@smtp_server = server
		end
		
		def smtp_port
			@smtp_port.nil? ? 25 : @smtp_port
		end
		
		def smtp_port=(port)
			@smtp_port = port
		end
		
		def helo_domain
			@helo_domain.nil? ? Socket.gethostname : @helo_comain
		end
		
		def helo_domain=(domain)
			@helo_domain = domain
		end
		
		def authentication
			@authentication
		end
		
		def authentication=(value)
			@authentication = case value.to_s
				when 'plain'
					:plain
				when 'login'
					:login
				when 'cram_md5'
					:cram_md5
				else
					@authentication
			end
		end

		def sent_on
			date
		end
		
		def sent_on=(value)
			self.date = value
		end
		
		def [](key)
			mail_obj[key]
		end
		
		def []=(key,value)
			mail_obj[key] = value
		end
		
		def generate_body
			@body_generated_flag = true
			email_context = Iowa::Context.new(session.context.request,Iowa::Response.new)
			email_context.sessionID = session.context.sessionID
            email_context.requestID = session.requestCount
			handleResponse(email_context)
			self.body = email_context.response_buffer
		end
		
		def encoded
			mail_obj.encoded
		end
		
		def send
			if @attachments
				content_type = 'multipart/mime'
				mime_version = '1.0'
			end
			generate_body unless body_generated?
			if smtp_connection
				smtp_connection.send_message(mail_obj.encoded, from, recipients)
			else
				args = []
				args.push smtp_account if smtp_account
				args.push smtp_password if smtp_password
				args.push authentication if authentication
				Net::SMTP.start(smtp_server, smtp_port, helo_domain, *args) {|smtp|
					smtp.send_message(mail_obj.encoded, from, recipients)
				}
			end
		end
		alias :send_email :send

	end
end
