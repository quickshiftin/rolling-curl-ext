namespace Rcurl\Group;

class Curl extends \Rcurl\Curl
{
	private group_callback = null;

	public function __construct(var callback=null)
	{
		let this->group_callback = callback;

		parent::__construct([$this, "process"]);
	}

	public function add(var request) -> bool
	{
		if(request instanceof \Rcurl\Group\Curl) {
			return request->addToRC(this);
        }

        return parent::add(request);
	}

	public function execute(var window_size=null) -> string|bool
    {
		if(count(this->__get("requests")) == 0) {
			return false;
        }

		return parent::execute(window_size);
	}

	protected function process(var output, var info, var request) -> void
	{
		if(request instanceof \Rcurl\Group\Curl) {
			request->process(output, info);
        }

		if(is_callable(this->group_callback)) {
			call_user_func(this->group_callback, output, info, request);
        }
	}
}

