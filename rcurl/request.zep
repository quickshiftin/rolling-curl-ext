namespace Rcurl;

class Request
{
	public url;
	public method;
	public post_data;
	public headers;
	public options;

    /**
     * @param string url
     * @param string method
     * @param post_data
     * @param headers
     * @param options
     */
    function __construct(url, method ="GET", post_data=null, headers=null, options=null)
    {
        let this->url       = url;
        let this->method    = method;
        let this->post_data = post_data;
        let this->headers   = headers;
        let this->options   = options;
    }

    public function __destruct()
    {
        \unset(this->url, this->method, this->post_data, this->headers, this->options);
    }
}
