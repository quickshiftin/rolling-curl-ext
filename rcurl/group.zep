namespace Rcurl;

// lib/RollingCurl/RollingCurlGroup.php
class Group
{
    protected name;
    protected num_requests = 0;
    protected finished_requests = 0;
    private requests = [];
}
