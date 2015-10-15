class Client
   def session
      @session || NSURLSession.sharedSession
   end
   
   def get(url)
     request = create_request(url)
     response(request)
   end
   
   def post(url, data)
     request = create_request(url, :POST) do |req|
       req.setValue("application/xml; charset=utf-8", forHTTPHeaderField:"Content-Type")
       req.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
     end
     response(request)
   end
   
   def data(request)
      response(request).then do |data, response|
         Promise.new.tap do |promise|
            promise.reject("Unknown Error") unless response.is_a?(NSHTTPURLResponse)
            if (200..300).include? response.statusCode
               promise.fulfill(data)
            else
               promise.reject("Server returned failure")
            end         
         end
      end
   end
   
   def JSON(request)
      data(request).then do |value|
        Promise.new.tap do |promise|
          error = Point.new(:object)
          json = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error)
          error[0].nil? ? promise.fulfill(json) : promise.reject(error[0])
        end
      end
   end
   
   private
   def create_request(url, meth=:GET)
     url = NSURL.URLWithString(url)
     request = NSMutableURLRequest.requestWithURL(url)
     request.HTTPMethod = meth
     yield(request) if block_given?
     request
   end
   
   def response(request)
      Promise.new.tap do |promise|
         task = session.dataTaskWithRequest(request, completionHandler:-> data, response, error {
            promise.reject(error) if data.nil? || response.nil?
            promise.fulfill([data, response])
         }).resume
      end
   end
   def escape_termina_string(value)
      value.stringByReplacingOccurrencesOfString("\"", withString: "\\\"", options:0, range: nil)
   end
   def convert_url_request_to_curl_command(request)
      method = request.HTTPMethod ?? "GET"
      retValue = "curl -i -v -X \(method) "
   end
end