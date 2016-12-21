namespace Rcurl\Group;

class Request extends \Rcurl\Request
{
    private group;

	/**
	 * Set group for this request
	 *
	 * @param group The group to be set
	 */
    public function setGroup(var group)
    {
        if(!(group instanceof Request)) {
            throw new \Rcurl\Group\Exception(
                "setGroup: group needs to be of instance Rcurl\Group\Request");
        }

        let this->group = group;
    }
}
