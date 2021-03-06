elasticsearch:
    image: elasticsearch:1.7.1
    ports:
        - "9200:9200"

kibana:
    image: kibana:4.1.1
    links:
        - elasticsearch
    ports:
        - "5601:5601"
