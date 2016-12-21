namespace Rcurl;

class Group
{
    protected name;
    protected num_requests = 0;
    protected finished_requests = 0;

    private requests = [];

    public function __construct(var name)
    {
       let $this->name = name;
    }

    public function add(var request)
    {
        if(request instanceof \Rcurl\Group\Request) {

            request->setGroup(this);

            let this->num_requests = this->num_requests++;

            this->requests[] = request;
        }
		elseif(is_array(request)) {
            for req in request {
                this->add(req);
            }
        }
        else {
            throw new \Rcurl\Group\Exception(
                "add: Request needs to be of instance Rcurl\Group\Request or an array");
        }

       return true;
    }
}
