"""
Prints out a deprecation warning indicating that a paricular usage
of rules_scala will not be supported in the future
"""
def console_print_deprecation(
    old_item,
    new_item
):
    _console_print(
        ["warning", "deprecation"],
        "%s is deprecated." % old_item,
        "Please use %s instead." % new_item,
        "deprecated: %s" % old_item,
        "supported : %s" % new_item
    )

"""
Helper method for consistently printing out structured messages from
rules_scala.
"""
def _console_print(
    mnemonic_crumbs,
    *lines
):
    mnemonic = "::".join(mnemonic_crumbs)
    print("\nrules_scala::{mnemonic}>>\n  {body}\n<<rules_scala::{mnemonic}".format(
        mnemonic = "::".join(mnemonic_crumbs),
        body = "\n  ".join(lines)))
