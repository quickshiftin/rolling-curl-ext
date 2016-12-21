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
     * @param  $callback
     * Callback function to be applied to each result.
     *
     * Can be specified as 'my_callback_function'
     * or array($object, 'my_callback_method').
     *
     * Function should take three parameters: $response, $info, $request.
     * $response is response body, $info is additional curl info.
     * $request is the original request
     *
     * @return void
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

    public function add(var item) {}
}

