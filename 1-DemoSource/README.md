# RudderStack Sources for demo purpose

## JavaScript Source

1. Download the Retail Demo Store Web UI code from: \<placeholder\>

2. Install the Node JS version 18+.

3. Run the following command to start the web UI locally:
    ```
    cd retail-demo-store-web-ui
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
