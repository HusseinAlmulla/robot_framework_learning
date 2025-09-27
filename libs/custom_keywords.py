from threading import current_thread

from robot.api.deco import keyword, library, not_keyword

#__all__ = ['example_keyword', 'calculate_sum']
#ROBOT_AUTO_KEYWORDS = True
#not_keyword(current_thread)    # Don't expose `current_thread` as a keyword.

@library
class CustomKeywords:

    def example_keyword(self):
        thread_name = current_thread().name
        print(f"Running in thread '{thread_name}'.")

    @keyword
    def calculate_sum(self, x, y):
        return self.sum_num(x, y)

    def sum_num(self, x, y):
        return x + y