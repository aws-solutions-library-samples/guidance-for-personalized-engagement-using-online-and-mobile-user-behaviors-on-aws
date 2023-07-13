
## 部署Data Plane到Amazon EKS（用于生产环境）

[English](README.md) | 中文

1. 创建AWS Cloud9服务器，执行CDK部署代码

    - 登录AWS控制台，进入Cloud9服务页面
    - 点击“创建环境”按钮，输入名称rs-deploy，选择环境类型（新的EC2实例）和实例类型t3.small，点击“创建”按钮
    - 等待Cloud9环境创建完成后，打开IDE，再打开终端窗口

2. 在AWS Cloud9环境里，使用AWS CDK代码部署Amazon EKS集群

    - 在终端窗口中，使用以下命令升级AWS CLI的版本: 
        ```
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install --bin-dir /usr/bin --update
        aws --version
        ```
        请确认版本是v2。
    
    - 运行`aws configure`命令，配置Access Key, Secret Key and Region.

    - 在终端窗口中，使用以下命令克隆代码仓库: `git clone https://github.com/aws-solutions-library-samples/guidance-for-digital-customer-engagement-on-aws.git`
    - 执行以下命令安装CDK项目的依赖:
        ```
        cd digital-customer-engagement-on-aws/2-DataCollection/DataPlaneDeployment
        
        # Upgrade CDK CLI
        npm install -g aws-cdk --force

        # Install Dependency
        npm ci
        ``` 
    - 修改bin/eks-blueprints.ts文件, 编辑变量赋予正确的值:
        ```
        const account = '<your_aws_account_id>';
        const region = '<your_deploy_region>';
        ```
    - 执行CDK deploy命令，部署EKS集群，遇到提示输入Y:
        ```
        cdk ls && cdk synth
        cdk deploy
        ```
3. 在Cloud9服务器上安装kubectl工具，并配置config文件，验证EKS集群可以正常访问。

    - 在终端窗口中，使用curl命令下载kubectl二进制文件: `curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.25.9/2023-05-11/bin/linux/amd64/kubectl`

    - 使用chmod命令修改kubectl二进制文件的权限: `chmod +x ./kubectl`

    - 将kubectl二进制文件移动到/usr/local/bin目录下: `sudo cp kubectl /usr/local/bin`

    - 在终端窗口中，使用aws eks update-kubeconfig命令更新kubeconfig文件，请查看CloudFormation的Outputs找到对应的命令，例如：
    `aws eks update-kubeconfig --name eks-blueprint --region ap-southeast-1 --role-arn arn:aws:iam::242057980000:role/eks-blueprint-eksblueprintAccessRoleBA6A9AAA-1O1NIG4CCTBBB`

    - 使用`kubectl get nodes`命令验证EKS集群可以正常访问


4. 在Amazon Route53服务上托管域名，创建Public的Hosted Zone

    - 登录AWS控制台，进入Route53服务页面
    - 点击“Create Hosted Zone”按钮，输入域名和描述，选择“Public Hosted Zone”选项，点击“Create Hosted Zone”按钮

5. 在AWS Certificate Manager上申请RudderStack Data Plane（以下简称为Data Plane）的子域名所对应的的Public证书

    - 登录AWS控制台，进入Certificate Manager服务页面
    - 点击“请求”按钮，选择“公有证书”，再点击下一步，输入完全限定域名(比如*.yourdomain.com)，点击“请求”按钮，等待证书验证通过

6. 在Amazon EKS上，安装Data Plane

    - 先安装helm工具，执行以下命令：`curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`
    - 先克隆Data Plane的Helm Chart的代码
        ```
        cd ~/environment
        git clone https://github.com/magicwind/rudderstack-helm.git
        cd rudderstack-helm
        ```
    - 修改配置文件values.yaml, 配置域名对应的参数"hostname"，然后使用helm install命令在EKS里安装Data Plane

    - 使用`helm install rs-release ./ --set rudderWorkspaceToken="<your-workspace-token>"`命令，在EKS集群中安装Data Plane。其中workspace token请在RudderStack Control Plane里查看。

    - 使用`kubectl get all`命令，查看Data Plane的所有组件是否都已经部署成功。

    - 使用`kubectl get ingress`命令，查看Application Load Balancer（简称ALB）创建的情况。成功的话，Address列会有ALB的域名。如果不成功，需要删除K8S里的Ingress组件`kubectl delete ingress/rs-release-rudderstack`，再通过helm upgrade命令重新部署Service组件。
        ```
        helm upgrade rs-release ./ --set rudderWorkspaceToken="<your-workspace-token>"
        ```

    - Ingress组件创建成功后，还需要在Route53的Hosted Zone中添加ALB的Alias DNS记录，将域名解析ALB上。

7. 验证部署，通过https的data plane域名在浏览器里测试data plane的url是否可以正常访问。
    - 在浏览器中，输入https://<data plane域名>，确认Data Plane的URL可以正常访问。服务正常的话会返回JSON
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