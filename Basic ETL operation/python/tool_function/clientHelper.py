from typing import Any, Callable
from typing_extensions import TypedDict
import opensilexClientToolsPython
import logging


class clientHelper:
    def __init__(self,
                 client: opensilexClientToolsPython.ApiClient = opensilexClientToolsPython.ApiClient(),
                 user: str = "admin@opensilex.org",
                 password: str = "admin",
                 host: str = "localhost:8080/rest",
                 ):
        self.user = user
        self.password = password
        self.host = host
        self.client = client

    def reconnect(self) -> None:
        self.client.connect_to_opensilex_ws(
            identifier=self.user, password=self.password, host=self.host)

    class _retry_output(TypedDict):
        result: str
        metadata: Any
        failed_loop: bool

    class _client_output(TypedDict):
        result: Any
        metadata: Any

    def retry_with_reconnect(self,
                             function: Callable[..., _client_output],
                             *positionalArguments,
                             default_return = None,
                             **argumentsDict
                             ) -> _retry_output:
        result = default_return
        failed_loop = False
        try:
            result = function(*positionalArguments, **argumentsDict)
        except Exception as e:
            self.reconnect()
            try:
                result = function(*positionalArguments, **argumentsDict)
            except Exception as e:
                logging.error(
                    f'Getting error while executing {function.__name__} with exeception {e}')
                failed_loop = True
        return {
            'result': result['result'],
            'metadata': result['metadata'],
            'failed_loop': failed_loop
        }
