namespace Rcurl;

/**
 * Class that holds a rolling queue of curl requests.
 *
 * @throws RollingCurlException
 */
class Curl
{
    /**
     * @var int
     *
     * Window size is the max number of simultaneous connections allowed.
     * 
     * REMEMBER TO RESPECT THE SERVERS:
     * Sending too many requests at one time can easily be perceived
     * as a DOS attack. Increase this window_size if you are making requests
     * to multiple servers or have permission from the receving server admins.
     */
    private window_size = 5;

    /**
     * @var float
     *
     * Timeout is the timeout used for curl_multi_select.
     */
    private timeout = 10;

    /**
     * @var string|array
     *
     * Callback function to be applied to each result.
     */
    private callback;

    /**
     * @var array
     *
     * Set your base options that you want to be used with EVERY request.
     */
    protected options = [];

    /**
     * @var array
     */
    private headers = [];

    /**
     * @var Request[]
     *
     * The request queue
     */
    private requests = [];

    /**
     * @var RequestMap[]
     *
     * Maps handles to request indexes
     */
    private requestMap = [];

    /**
     * @var returns[]
     *
     * All returns of requests
     */
    private returns = [];

    /**
     * @var bool
     *
     * Save responses option; needs to be enabled to store responses
     */
    private saveResponses = true;

    /**
     * @param  $callback
     * Callback function to be applied to each result.
     *
     * Can be specified as 'my_callback_function'
     * or array($object, 'my_callback_method').
     *
     * Function should take three parameters: $response, $info, $request.
     * $response is response body, $info is additional curl info.
     * $request is the original request
     */
    public function __construct(var callback=null) -> void
    {
        let this->callback = callback;

        let this->options = [
            CURLOPT_SSL_VERIFYPEER : false,
            CURLOPT_RETURNTRANSFER : true,
            CURLOPT_CONNECTTIMEOUT : 30,
            CURLOPT_TIMEOUT        : 30
        ];
    }

    public function disableResponseSaving()
    {
        let this->saveResponses = false;
    }

    /**
     * Add a request to the request queue
     *
     * @param Request $request
     * @return bool
     */
    public function add(var request) -> bool
    {
         let this->requests[] = request;

         return true;
    }

    /**
     * @param \returns[] $returns
     */
    public function setReturns(var returns) -> void
    {
        let this->returns = returns;
    }

    /**
     * @return \returns[]
     */
    public function getReturns() -> array
    {
        return this->returns;
    }

    /**
     * Create new Request and add it to the request queue
     *
     * @param string $url
     * @param string $method
     * @param  $post_data
     * @param  $headers
     * @param  $options
     * @return bool
     */
    public function request(
        var url, var method="GET", var post_data=null, var headers=null, var options=null
    ) -> bool
    {
         let this->requests[] = new Request(url, method, post_data, headers, options);

         return true;
    }

    /**
     * Perform GET request
     *
     * @param string $url
     * @param  $headers
     * @param  $options
     *
     * @return bool
     */
    public function get(var url, var headers=null, var options=null) -> bool
    {
        return this->request(url, "GET", null, headers, options);
    }

    /**
     * Perform POST request
     *
     * @param string $url
     * @param  $post_data
     * @param  $headers
     * @param  $options
     *
     * @return bool
     */
    public function post(var url, var post_data=null, var headers=null, var options=null) -> bool
    {
        return this->request(url, "POST", post_data, headers, options);
    }

    /**
     * Execute the curl
     *
     * @param int $window_size Max number of simultaneous connections
     *
     * @return string|bool
     */
    public function execute(var window_size=null) -> string|bool
    {
        // rolling curl window must always be greater than 1
        if(sizeof(this->requests) == 1) {
            return this->single_curl();
        }

        // start the rolling curl. window_size is the max number of simultaneous connections
        return this->rolling_curl(window_size);
    }

    /**
     * Performs a single curl request
     *
     * @access private
     * @return string
     */
    private function single_curl() -> string|bool
    {
        var ch      = curl_init();      
        var request = array_shift(this->requests);
        var options = this->get_options(request);

        curl_setopt_array(ch, options);

        var output = curl_exec(ch);
        var info   = curl_getinfo(ch);
        var error  = curl_error(ch);

        // it's not neccesary to set a callback for one-off requests
        if(this->callback) {
            if(is_callable(this->callback)) {
                call_user_func(this->callback, output, info, request, error);
            }
        }
		else {
            return output;
        }

        return true;
    }

    /**
     * Helper function to set up a new request by setting the appropriate options
     *
     * @access private
     * @param Request $request
     *
     * @return array
     */
    private function get_options(var request) -> array
    {
        // options for this entire curl object
        var options = this->__get("options");

        // NOTE: The PHP cURL library won"t follow redirects if either safe_mode is on
        // or open_basedir is defined.
        // See: https://bugs.php.net/bug.php?id=30609
		if((ini_get("safe_mode") == "Off" || !ini_get("safe_mode")) &&
           ini_get("open_basedir") == "")
        {
            let options[CURLOPT_FOLLOWLOCATION] = 1;
			let options[CURLOPT_MAXREDIRS]      = 5;
        }
        var headers = this->__get("headers");

		// append custom options for this specific request
		if(request->options) {
            let options = request->options + options;
        }

		// set the request URL
        let options[CURLOPT_URL] = request->url;

        // posting data w/ this request?
        if(request->post_data) {
            let options[CURLOPT_POST]       = 1;
            let options[CURLOPT_POSTFIELDS] = request->post_data;
        }

        if(headers) {
            let options[CURLOPT_HEADER]     = 0;
            let options[CURLOPT_HTTPHEADER] = headers;
        }
        
        // Due to a bug in cURL CURLOPT_WRITEFUNCTION must be defined as the last option
        // Otherwise it doesn't register. So let's unset and set it again
        // See http://stackoverflow.com/questions/15937055/curl-writefunction-not-being-called
        if(!empty(options[CURLOPT_WRITEFUNCTION])) {
            var writeCallback = options[CURLOPT_WRITEFUNCTION];

            unset(options[CURLOPT_WRITEFUNCTION]);

            let options[CURLOPT_WRITEFUNCTION] = writeCallback;
        }

        return options;
    }

    public function __get(var name)
    {
        return (isset(this->{name})) ? this->{name} : null;
    }

    public function __set(var name, var value) -> bool
    {
        // append the base options & headers
        if(name == "options") {
            let this->options = array_merge(this->options, value);
        } elseif(name == "headers") {
            let this->headers = array_merge(this->headers, value);
        } else {
            let this->{name} = value;
        }

        return true;
    }

    /**
     * Performs multiple curl requests
     *
     * @access private
     * @throws RollingCurlException
     * @param int $window_size Max number of simultaneous connections
     * @return bool
     */
    private function rolling_curl(var window_size=null) -> bool
    {
        if(window_size) {
            let this->window_size = window_size;
        }

        // make sure the rolling window isn't greater than the # of urls
        if(sizeof(this->requests) < this->window_size) {
            let this->window_size = sizeof(this->requests);
        }
        
        if(this->window_size < 2) {
            throw new Exception("Window size must be greater than 1");
        }

        var master = curl_multi_init();        

        // start the first batch of requests
        var i = 0;
        var ch, options, key;
        while(i < this->window_size) {
            let ch      = curl_init();
            let options = this->get_options(this->requests[i]);

            curl_setopt_array(ch, options);
            curl_multi_add_handle(master, ch);

            // Add to our request Maps
            let key                   = (string)ch;
            let this->requestMap[key] = i;

            let i = i + 1;
        }

        var execrun, running, runningInside;
        var info, output, sCurlErr, errorno, errno, callback, request;

        do {
            loop {
                let execrun = curl_multi_exec(master, running);

                if(execrun != CURLM_CALL_MULTI_PERFORM) {
                    break;
                }   
            }

            if(execrun != CURLM_OK) {
                break;
            }

            // a request was just completed -- find out which one
            loop {
                let runningInside = curl_multi_info_read(master);

                if(!runningInside) {
                    break;
                }

                // get the info and content returned on the request
                let info     = curl_getinfo(runningInside["handle"]);
                let output   = curl_multi_getcontent(runningInside["handle"]);
                let sCurlErr = "";
                let errorno  = curl_errno(runningInside["handle"]);

                if(errorno) {
                    let sCurlErr = curl_strerror(errno);
                }

                // @note Saving the response of all the requests adds up when you pass a large number of urls!
                if(this->saveResponses) {
                    array_push(this->returns, [
                        "return" : output,
                        "info"   : info
                    ]);
                }

                // send the return values to the callback function.
                let callback = this->callback;
                if(is_callable(callback)) {
                    let key     = (string)runningInside["handle"];
                    let request = this->requests[this->requestMap[key]];
                    unset(this->requestMap[key]);
                    call_user_func(callback, output, info, request, sCurlErr);
                }

                // start a new request (it's important to do this before removing the old one)
                if(i < sizeof(this->requests) && isset(this->requests[i]) && i < count(this->requests)) {
                    let ch      = curl_init();
                    let options = this->get_options(this->requests[i]);

                    curl_setopt_array(ch, options);
                    curl_multi_add_handle(master, ch);

                    // Add to our request Maps
                    let key = (string)ch;
                    let this->requestMap[key] = i;
                    let i = i + 1;
                }

                // remove the curl handle that just completed
                curl_multi_remove_handle(master, runningInside["handle"]);
            }

            // Block for data in / output; error handling is runningInside by curl_multi_exec
            if(running) {
                curl_multi_select(master, this->timeout);
            }

        } while(running);

        curl_multi_close(master);

        return true;
    }
}
