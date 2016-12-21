namespace Rcurl;

class Request
{
	public url       = false;
	public method    = 'GET';
	public post_data = null;
	public headers   = null;
	public options   = null;

    /**
     * @param string url
     * @param string method
     * @param post_data
     * @param headers
     * @param options
     */
    function __construct(url, method ="GET", post_data=null, headers=null, options=null)
    {
        this->url       = url;
        this->method    = method;
        this->post_data = post_data;
        this->headers   = headers;
        this->options   = options;
    }

    public function __destruct()
    {
        unset($this->url, $this->method, $this->post_data, $this->headers, $this->options);
    }
}
