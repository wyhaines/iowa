require 'iowa/Constants'
require 'digest/sha1'

module Iowa

  # An instance of Policy implements all of the functions
  # surrounding session key creation and validation as well
  # as the handling of getting/setting request and action
  # ids in a URL or in a cookie.  This class implements the
  # default IOWA policies in these areas and also serves
  # as a template for the API that other policy classes
  # must deliver.
  
  class Policy

    RNDSesFormat = '%08x'.freeze

    MatchURL = Regexp.new('(/*(?:[^/]*/*)*?)(\w+\-\w+\-\w+\.\w+\.[\w\.]+)*(-\w+)?$')

    def initialize(args)
      args = {:prng => Kernel} if args and args.empty?
      args[:prng] ||= Kernel
      @prng = args[:prng]
    end

    def rand(num)
      @prng.rand(num)
    end

    def new_session_key
      r1 = sprintf(RNDSesFormat,@prng.rand(2147483647))
      r2 = sprintf(RNDSesFormat,@prng.rand(2147483647))
      tn = Time.now
      t = Digest::SHA1.hexdigest("#{tn.tv_sec}#{tn.tv_usec}")[C_0to7]
      id = "#{r1}-#{r2}-#{t}"
    end

    def getIDs(url)
      if (match = MatchURL.match url)
        urlRoot = match[1]
        remainder = match[2]? match[2] : C_empty
        urlRoot.sub!(/\/$/,C_empty)
        sessionID, requestID, actionID = remainder.split(C_dot,3)
        [urlRoot, sessionID, requestID, actionID]
      else
        [nil,nil,nil,nil]
      end
    end

    def baseURL(context)
      context.urlRoot != '' ? "#{context.urlRoot}" : '/'
    end

    def sessionURL(context)
        "#{context.urlRoot}/#{context.sessionID}"
    end

    def actionURL(context)
      Iowa.app.location.to_s != C_empty ?
        "#{context.urlRoot}/#{context.sessionID}.#{context.requestID}.#{context.elementID}-#{Iowa.app.location}" :
        "#{context.urlRoot}/#{context.sessionID}.#{context.requestID}.#{context.elementID}"
    end

    def locationFlag(context)
      Iowa.app.location.to_s != C_empty ?
        "-#{Iowa.app.location}" : C_empty
    end

  end
end
