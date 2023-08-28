
## Mock Event Data Generation

To generate mock events and send them to RudderStack data plane

1. Obtain the Write Key from your JavaScript source in RudderStack control plane.

2. Obtain the RudderStack data plane host

3. to run make_fake_data.py: first create a python3 virtual environment and then activate this virutual environment.

   Inside the virtual environment and execute following commands sequentially (remember to replace the variable placeholder<> with real value).
    ```
    pip install -r requirements.txt
    export RS_DATA_PLANE=https://<data-plane-host>
    export RS_WRITE_KEY=<source-write-key>

    python make_fake_data.py
    ```
