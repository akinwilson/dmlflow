# Machine Learning Operations in Production
Infrastructure for machine learning operations. Want to remotely host a data store for machine learning. Will use Mlflow for systematically recording experiments, AWS fargate to host the mlflow server remotely, AWS S3 as a artifact store (model weights, ids-to-tokens, etc.) and AWS Aurora database management service for the backend store of Mlflow (model metrics, version info, etc. )

## Architecture proposal
![](media/mlopsSetup.png "ML operations architecture diagram")
Incoming requests are sent to the application load balancer, forwarding to the fargate task serving the MLFlow tracking server. Any responses from the server are routed through the network address translation gateway between the private and public subnets, and backout the internet gate to the tracking service user.

**Note no authentication is set up yet, will be using basic single user authentication via an Nginx Proxy** 

**Note** When wanting to configure the tracking server as below, there is a conflict between the flags: `--default-artifact-root` and `--artifacts-destination`. 

*Option 'default-artifact-root' is required, when backend store is not local file based*

This suggests that artifacts are fire written to storage locally (to the fargate task) and later sent to their artifact destination. The implications are: A Reasonable storage ammount should be provided to the fargate task, possibly a NFS. 



## MLFlow related logic
![](media/mlflow-config.png "MLFlow configuration")
To restrict public access to the artifact and backend store, a remote host is used as a proxy to interact with the storage services. 

**Note**: Using Mysql backend __not__ PostgreSQL as the diagram suggests.


