
## Deploying Data Plane to Amazon EKS (for production environment)

English | [中文](README_CN.md)

1. Create an AWS Cloud9 instance and execute CDK deployment code.

    - Log in to the AWS console and navigate to the Cloud9 service page.
    - Click on the "Create environment" button, enter the name "rs-deploy," select the environment type (new EC2 instance), choose the instance type as t3.small, and click the "Create" button.
    - Wait for the Cloud9 environment to be created and open the IDE. Then, open a terminal window.

2. Deploy the Amazon EKS cluster using AWS CDK code within the AWS Cloud9 environment.

    - In the terminal window, use the following command to upgrade the AWS CLI version:
        ```
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install --bin-dir /usr/bin --update
        aws --version
        ```
        Please make sure the version is v2.
    
    - Run the `aws configure` command to configure the Access Key, Secret Key, and Region. 

    - In the terminal window, use the following command to clone the code repository: `git clone https://github.com/aws-solutions-library-samples/guidance-for-personalized-engagement-using-online-and-mobile-user-behaviors-on-aws.git`
    - Execute the following command to install the dependencies for the CDK project:
        ```
        cd guidance-for-personalized-engagement-using-online-and-mobile-user-behaviors-on-aws/2-DataCollection/DataPlaneDeployment
        
        # Upgrade CDK CLI
        npm install -g aws-cdk --force

        # Install Dependency
        npm ci
        ``` 
    - Export environment variables:
        ```
        export CDK_DEFAULT_ACCOUNT=<your_aws_account_id>;
        export CDK_DEFAULT_REGION=<your_deploy_region>;
        ```
    - Execute the CDK deploy command to deploy the EKS cluster and respond with "Y" when prompted:
        ```
        cdk ls && cdk synth
        cdk deploy
        ```
3. Install the kubectl tool on the Cloud9 server and configure the config file to verify that the EKS cluster can be accessed properly.

    - In the terminal window, use the curl command to download the kubectl binary: `curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.25.9/2023-05-11/bin/linux/amd64/kubectl`

    - Use the chmod command to modify the permissions of the kubectl binary: `chmod +x ./kubectl`

    - Move the kubectl binary to the /usr/local/bin directory: `sudo cp kubectl /usr/local/bin`

    - In the terminal window, use the aws eks update-kubeconfig command to update the kubeconfig file. Please refer to the CloudFormation Outputs to find the corresponding command, for example：
    `aws eks update-kubeconfig --name eks-blueprint --region ap-southeast-1 --role-arn arn:aws:iam::<aws-account-id>:role/eks-blueprint-eksblueprintAccessRoleBA6A9AAA-1O1NIG4CCTBBB`

    - Use the kubectl get nodes command to verify that the EKS cluster can be accessed properly.

4. Host the domain on Amazon Route53 and create a public hosted zone.

    - Log in to the AWS console and go to the Route53 service page.
    - Click on the "Create Hosted Zone" button, enter the domain name and description, select the "Public Hosted Zone" option, and click the "Create Hosted Zone" button.

5. Apply for a public certificate for the subdomain of RudderStack Data Plane using AWS Certificate Manager.

    - Log in to the AWS console and go to the Certificate Manager service page.
    - Click on the "Request" button, select "Public Certificate," then click Next. Enter the fully qualified domain name (e.g., *.yourdomain.com) and click the "Request" button. Wait for the certificate validation to pass.

6. Install Data Plane on Amazon EKS.

    - First, install the Helm tool by executing the following command: `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`
    - Clone the Helm Chart code for Data Plane:
        ```
        cd ~/environment
        git clone https://github.com/magicwind/rudderstack-helm.git
        cd rudderstack-helm
        ```
    - Modify the configuration file `values.yaml` to configure the parameters for the domain name under the "hostname" section. Then, use the `helm install` command to install Data Plane in EKS.

    - Use the command `helm install rs-release ./ --set rudderWorkspaceToken="<your-workspace-token>"` to install Data Plane in the EKS cluster. The workspace token can be obtained from the RudderStack Control Plane.

    - Use the `kubectl get all` command to check if all components of Data Plane have been successfully deployed.

    - Use the `kubectl get ingress` command to check the status of the Application Load Balancer (ALB) creation. If successful, the "Address" column will display the ALB's domain name. If not successful, delete the Ingress component in K8S using `kubectl delete ingress/rs-release-rudderstack`, and then redeploy the Service component using the `helm upgrade` command.
        ```
        helm upgrade rs-release ./ --set rudderWorkspaceToken="<your-workspace-token>"
        ```

    - After the Ingress component is successfully created, add an Alias DNS record for the ALB in the Route53 Hosted Zone to resolve the domain name to the ALB.

7. In Amazon Route53's hosted zone, create domain name resolution records for the data plane service.

    - Open the Hosted Zone administration interface.
    - Click the “Create Record” button.
    - Enter "dataplane" under record name textbox, check "Alias" option, select "Applicaiton and Classic Load Balancer" in route traffic to's selection, then select the region and load balancer, edit the load balancer's address, Delete "dualstack." in the address, keep only the following address, and finally click the Create Record button.

8. Verify the deployment by testing the URL of the Data Plane using the HTTPS data plane domain in a web browser.

    - In a web browser, enter `https://<data plane domain>`, and confirm that the URL of the Data Plane can be accessed successfully. If the service is functioning properly, it should return a JSON response.  
        ```
        {
            "appType": "EMBEDDED",
            "server": "UP",
            "db": "UP",
            "acceptingEvents": "TRUE",
            "routingEvents": "TRUE",
            "mode": "NORMAL",
            "backendConfigMode": "API",
            "lastSync": "2023-06-21T09:46:50Z",
            "lastRegulationSync": ""
        }
        ```

9. (optional) If you want to uninstall RudderStack Data Plane service, please execute following commands:
    ```
    # First uninstall the helm chart of the Data Plane
    helm uninstall rs-release

    # Then delete the CloudFormation stack of the Amazon EKS cluster created by AWS CDK
    cdk destroy --all
    ```