namespace Rcurl;

use \Rcurl\Group\Exception as Exception;

class Group
{
    protected name;
    protected num_requests = 0;
    protected finished_requests = 0;

    private requests = [];

    public function __construct(var name)
    {
       let this->name = name;
    }

    public function add(var request) -> boolean
    {
        if(request instanceof \Rcurl\Group\Request) {
            request->setGroup(this);

            let this->num_requests = this->num_requests + 1;

            let this->requests[] = request;

            return true;
        }
		elseif(is_array(request)) {
            var req;
            for req in request {
                this->add(req);
            }

            return true;
        }

        throw new Exception(
            "add: Request needs to be of instance Rcurl\Group\Request or an array");
    }

    public function addToRC(<\Rcurl\Curl> rc) -> bool
    {
        while(count(this->requests) > 0) {
            if(!rc->add(array_shift(this->requests))) {
                return false;
            }
        }

        return true;
    }

    public function process(var output, var info, var request) -> void
    {
        let this->finished_requests = this->finished_requests + 1;

        if(this->finished_requests >= this->num_requests) {
            this->finished();
        }
    }

    public function finished() -> void {}
}
