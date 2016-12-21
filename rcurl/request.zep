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
    public function __construct(var url, var method="GET", var post_data=null, var headers=null, var options=null)
    {
        let this->url       = url;
        let this->method    = method;
        let this->post_data = post_data;
        let this->headers   = headers;
        let this->options   = options;
    }
}
