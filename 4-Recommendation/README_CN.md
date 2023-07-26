# 个性化推荐：使用RudderStack和Amazon Personalize做集成

[English](README.md) | 中文

请按照以下步骤完成Amazon Personalize服务和RudderStack的配置，并在Retail Demo Store里体验实时的个性化商品推荐。

0. 配置Amazon Personalize服务

   依次执行[Prepare-Personalize-and-import-data notebook](Prepare-Personalize-and-import-data.ipynb)的代码，创建Dataset Group, Dateset和Event Tracker.

1. 在RudderStack的Control Plane里创建Destination.

   选中左侧Destinations菜单，点击"New destination"，在Search Destinations搜索框里输入personalize, 选择下面出现的AWS Personalize。

   在Name destination里输入目标的名字，比如aws_personalize_dev.

   在Connect Sources步骤，选择之前在1-DemoSource里创建的JavaScript source，点击Continue按钮继续。

   在Configure步骤，在1. Connection Credentials下面，取消Role Based Authentication选项。

   在Access Key Id和Secret Access Key里输入在步骤2-DataCollection/RedshiftDestination的Setup Access Key and Secret Key里生成的密钥对。

   Region里填写Amazon Personalize服务所在的区域代码，注意最好和RudderStack Data Plane部署在同一个区域。

   在"2. Information on Dataset Group"下面的TrackingId里填写，步骤0生成的Event Tracking ID。Dataset ARN里填写步骤0创建的Dataset ARN。

   在"3. Operational Choice"下面的Personalize Events里选择PutEvents，Map all the fields里按以下信息填写：
   ```
   Schema Field   Mapped Field
   ---------------------------
   ITEM_ID        productid
   DISCOUNT       discount
   ```

   在Transformation步骤里，点击"Create New Transformation", 选择Custom transformation, Transformation name里输入filter, 复制transformation.js代码到代码编辑器里，
   点击Continue按钮2次，完成Destination的创建。


2. 运行1-DemoSource里的Retail Demo Store Web UI。

   对于Guest用户会显示Popular products。
   ![](images/personalize-2.png)
   
   对于Login用户会显示Inspired by your shopping trends
   ![](images/personalize-3.png)

   打开RudderStack Control Plane，打开AWS Personalize Destination的Live Events界面，然后在网站上点击商品打开商品详情页，可以看到类似的事件实时的发送到了Amazon Personalize服务。
   ![](images/personalize-1.png)

   通过不断的进行商品浏览行为或者购买行为，观察推荐列表的变化。

   也可以先注册一个账号再登录，然后通过右上角切换Persona来模拟不同的用户画像。
   ![](images/personalize-4.png)

   ![](images/personalize-5.png)