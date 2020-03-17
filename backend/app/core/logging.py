
def use_logging_handler():

    # Imports the Google Cloud client library
    import google.cloud.logging

    # Instantiates a client
    client = google.cloud.logging.Client()

    # Connects the logger to the root logging handler; by default this captures
    # all logs at DEBUG level and higher
    client.setup_logging(log_level=logging.debug)
