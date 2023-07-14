
## Mock Event Data Generation

To generate mock events and send them to RudderStack data plane

1. Obtain the Write Key from your JavaScript source in RudderStack control plane.

2. Obtain the RudderStack data plane host

3. to run make_fake_data.py
    ```
    pip3 install -r requirements.txt
    export RS_DATA_PLANE=https://<data-plane-host>
    export RS_WRITE_KEY=<source-write-key>

    python3 make_fake_data.py
    ```
