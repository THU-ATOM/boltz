docker build -t boltz-predict . \
    --build-arg "http_proxy=http://10.0.0.12:8001" \
    --build-arg "https_proxy=http://10.0.0.12:8001"