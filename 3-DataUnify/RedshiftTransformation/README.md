# Data Modeling on Amazon Redshift

This is a [dbt project](https://www.getdbt.com/product/what-is-dbt/) consists of three kinds of data models for different use cases:
1. Event Analytics
2. User Profile
3. Attribution Analytics

This project runs as a scheduled job in Apache Airflow.

## Event Analytics
Using RudderStack eventstream data, [this model](transform/rudder-ecommerce/models/events_analytics/) creates several metrics tables that can be plugged into various visualisation tools such as Amazon Quicksight and Tableau.

### Metrics Created
1. DAU: Daily Active Users count (a user is counted as DAU if they have atleast one tracks or pages event)
2. total_sessions: Total sessions in a given day. This would be >= DAU, as many users have multiple sessions in a day
3. bounce_rate: If a user visits a single page and their session length is zero, that's counted as a bounced session. This metric shows the percentage of sessions that have zero session length
4. avg_session_length: This is the avg session length in seconds, across all users

## User Profile

RudderStack has various tracking plans, one of which is [e-commerce event tracking](https://www.rudderstack.com/docs/event-spec/ecommerce-events-spec/). In this model, we assume that the event stream sdk is implemented with the tracking plan recommended by RudderStack. With that assumption, we generate various user featuers in this dbt project. The output of this project is a table in warehouse, with one row per user, containing different attributes/features of the user. The featuers come from five groups at a high level.
The complete list of the features is listed below:

### Features List

- [traits features](transform/rudder-ecommerce/models/data_model/stg_traits): These are related to user, which do not, or rarely change. They are created from the latest identify call for a given user
    1. gender (char)
    2. age_in_years (int)
    3. country (str)
    4. state (str)
    5. email_domain (str)
    6. has_mobile_app (bool)
    7. campaign_sources (Array[str])
    8. is_active_on_website (bool)
    9. days_since_account_creation (int)
    10. payment_modes <list of all payment modes ever (cod, credit card, debit card, wallet etc)> (List[str])
- [Engagement features](transform/rudder-ecommerce/models/data_model/stg_engagement_based): These are related to the time a user spends on the website/app.
    1. days_since_last_seen (int)
    2. is_churned_n_days (bool)
    3. active_days_in_past_n_days (int)
    4. Session based:  (a new session begins when the time since previous session becomes > n min, with n being a variable)
        1. avg_session_length_last_week (float)
        2. n_sessions_last_week (int)  
        3. avg_session_length_overall (float)
        4. n_sessions_overall (int)
- [Revenue based features](transform/rudder-ecommerce/models/data_model/stg_revenue_based): These are related to the amount users spend
    1. amt_spent_in_past_n_days (float)
    2. total_amt_spent (float)
    3. last_transaction_value (float)
    4. average_transaction_value (float)
    5. average_units_per_transaction (float)
    6. median_transaction_value (float)
    7. highest_transaction_value (float)
    8. days_since_last_purchase (int)
    9. transactions_in_past_n_days (int)
    10. total_transactions (int)
    11. has_credit_card (bool)
- [Pre-revenue features](transform/rudder-ecommerce/models/data_model/stg_pre_revenue_based): Related to the pre-checkout engagement features such as cart adds, abandoned carts etc
    1. carts_in_past_n_days
    2. total_carts
    3. products_added_in_past_n_days (both purchased and not purchased)
    4. total_products_added_to_cart
    5. days_since_last_cart_add (int)
- [SKU based features](transform/rudder-ecommerce/models/data_model/stg_sku_based): Related to the SKU, categories etc. 
    1. items_purchased_ever (List of unique product items, List[str]); Max size is controlled from variable `var_max_list_size`; IF a user has more than this number, such users get null result. If this number is too large, it can create performance issues.
    2. categories_purchased_ever (List of unique category ids, List[str]); Max size is controlled from variable `var_max_list_size`; IF a user has more than this number, such users get null result. If this number is too large, it can create performance issues.
    3. highest_spent_category (str) (based on the price of the products); Max size is controlled from variable `var_max_cart_size`; If a user has more than this number of distinct categories, it limits to the random `var_max_cart_size` number of categories. If this number is too large, it can create performance issues.
    4. highest_transacted_category (str); Max size is controlled from variable `var_max_cart_size`; If a user has more than this number of distinct categories, it limits to the random `var_max_cart_size` number of categories. If this number is too large, it can create performance issues.

### Prerequisites:
Event-stream sdk implemented following e-commerce event spec. Only below events are required. Within each table, the required columns can be checked from the dbt_project.yml file variables.
    1.1 tracks
    1.2 identifies
    1.3 product_added
    1.4 checkout_step_completed
    1.5 order_completed

### Output:
The model creates two main output tabels, `event_stream_customer_features` and `event_stream_feature_table`;  The `event_stream_feature_table` has features in long format, with following columns: `user_id, timestamp, feature_name, feature_type, feature_value_<numeric|string|array>`; The same data is presented in a wide form (pivoted data) in `event_stream_customer_features` table with one row per user_id for a given timestamp. 

There are a few other tables that get created, with prefix `stg_`; They are not required beyond the project run and can safely be ignored. At each run, these temp tables get replaced.


## Attribution Analytics

This model contains dbt code related to the Attribution use case. We have tried to build a dbt model that can create "session" abstractions on top of web page views of a user on one or more RudderStack web properties. The session information from these dbt models can then be used in conjunction with transaction and referrer data for various attribution related analysis.

The model is defined in [web_attribution](transform/rudder-ecommerce/models/web_attribution/).


### Setting up

1. As long as the events are instrumented following the e-commerce spec, no changes in the sql files are required. All the changes can be done from the `dbt_project.yml` file. The key variables that require to be changed are:

    ````
    vars:
    rs_database: 'dev'                    #This is the name of database where the event stream tables are all stored.
    rs_schema: 'h_5'                      #This is the name of schema where the event stream tables are all stored
    start_date: '2023-01-01'              #This is the lower bound on date. Only events after this date would be considered. Typically used to ignore data during test setup days. 
    end_date: 'now'                       #This is the upper bound on date .Default is 'now'; It can be modified to some old date to create snapshot of features as of an older timestamp
    date_format: 'YYYY-MM-DD'             # This is the date format
    session_cutoff_in_sec: 1800           # A session is a continuous sequence of events, as long as the events are within this interval. If two consecutive events occur at an interval of greater than this, a new session is created.
    lookback_days: [7,30,90,365]          # There are various lookback features such as amt_spent_in_past_n_days etc where n takes values from this list. If the list has two values [7, 30], amt_spent_in_past_7_days and amt_spent_in_past_30_days are computed for ex.
    product_ref_var: 'sku'                #This is the name of the property in the tracks calls that uniquely corresponds to the product
    category_ref_var: 'category'          #This is the name of the property in the tracks calls that corresponds to the product category
    main_id: 'dbt_visitor_id'             # The identifier column name in id graph output table 
    ````

   Along with the above variables, the table names (variables that start with `tbl_` prefix) may need to be changed depending on the schema, both in the dbt_project.yml file and in schema.yml file if they deviate from the ecommerce spec. 

2.  To run the DBT project locally, install the dbt core and dbt redshift plugin. 

    Config the profiles.xml in ~/.dbt/ folder.

    Execute following command to run the project:
    ```
    cd transform/rudder-ecommerce
    dbt run
    ```

3.  To run the DBT project in Apache Airflow. Install docker and docker-compose tools firstly.

    Then build Airflow Image locally to install additional python dependencies:
    `docker-compose build`

    Then config DBT profile for connecting to the Redshift.
    ```
    cp .env.template .env
    vim .env
    ```

    Next, to start Airflow, run the following command:
    `docker-compose up -d`

    If there is any change to the python packages, try to re-build the Airflow Image using command below:
    `docker-compose build`
