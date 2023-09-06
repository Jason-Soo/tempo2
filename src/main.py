#Local Repo - v0.9.29.0
#source from src/c7n_gcp/mu.py L288-355
#https://github.com/InsigniaFinancial/gcp-cloud-custodian/blob/1af1734bd1987db1a2a81c11becb07fb2212ca9d/src/c7n_gcp/mu.py#L288C1-L355C14

#Official Repo
#https://github.com/cloud-custodian/cloud-custodian/blob/7f4689d46aece6fb371dee71d79ea5dac61c774d/tools/c7n_gcp/c7n_gcp/mu.py#L287C1-L355C14

import base64
import json
import traceback
import os
import logging
import sys
import pprint

from flask import Request, Response

log = logging.getLogger('custodian.gcp')

# get messages to cloud logging in structured format so we can filter on severity.

class CloudLoggingFormatter(logging.Formatter):
    '''Produces messages compatible with google cloud logging'''
    def format(self, record: logging.LogRecord) -> str:
        s = super().format(record)
        return json.dumps(
            {
                "message": s,
                "severity": record.levelname,
                "timestamp": {"seconds": int(record.created), "nanos": 0},
            }
        )


def init():
    root = logging.getLogger()
    handler = logging.StreamHandler(sys.stdout)
    formatter = CloudLoggingFormatter(fmt="[%(name)s] %(message)s")
    handler.setFormatter(formatter)
    root.addHandler(handler)
    root.setLevel(logging.DEBUG)


init()


def run(event, context=None):

    # gcp likes to change values incompatibily, SIGNATURE is current value.
    # per documentation python3.7 runtimes is supposed to use the TRIGGER, but
    # it seems like that is not the case. newer runtimes all use SIGNATURE
    trigger_type = os.environ.get(
        'FUNCTION_TRIGGER_TYPE',
        os.environ.get('FUNCTION_SIGNATURE_TYPE', '')
    )

    if isinstance(event, Request):
        event = event.json

    log.info("starting function execution trigger:%s event:%s", trigger_type, event)
    if trigger_type in ('HTTP_TRIGGER', 'http',):
        event = {'request': event}
    else:
        event = json.loads(base64.b64decode(event['data']).decode('utf-8'))

    try:
        from c7n_gcp.handler import run
        result = run(event, context)
        log.info("function execution complete")
        if trigger_type in ('HTTP_TRIGGER', 'http',):
            return json.dumps(result), 200, (('Content-Type', 'application/json'),)
        return result
    except Exception as e:
        traceback.print_exc()
        raise
