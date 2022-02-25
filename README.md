# mlops
infrastructure for machine learning operations

**Production environment set up**
User -> reversed linked-account authorised proxy -> MLFlow sever { backend store and artifact store }

![Note no authentication is shown in diagram, but will be added behind load balancer using reversed proxy. See: https://github.com/ntropy-network/oauth2-proxy ](img/mlopsSetup.jpg "ML operations architecture diagram")


