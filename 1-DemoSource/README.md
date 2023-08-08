# RudderStack Sources for demo purpose

## JavaScript Source

1. Download the Retail Demo Store Web UI code from: [retail-demo-store-rudderstack](https://github.com/fengxu1211/retail-demo-store-rudderstack).

   Then download [.env.template]() and save the file to the project folder.

2. Install the Node JS LTS version on your development environment.

3. Run the following command to start the web UI locally:
    ```
    cd retail-demo-store-rudderstack
    cp .env.template .env
    ```
    And then set following two variables in .env:
    ```
    VUE_APP_RUDDERSTACK_WRITE_KEY=
    VUE_APP_RUDDERSTACK_URL=
    ```
    Next, to install dependencies and start the web server locally.
    ```
    npm ci
    npm run serve
    ```
4. To modify the tracking code using  RudderStack SDK, you can edit the `src/analytics/AnalyticsHandler.js`
