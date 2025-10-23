import datetime

project = "IMAS EasyBuild Setup Guide"
copyright = f"{datetime.datetime.now().year}, ITER Organization"
author = "ITER Organization"
html_theme = "sphinx_immaterial"
html_title = project

extensions = [
    "sphinx.ext.todo",
    # "sphinx.ext.autosectionlabel",
    "sphinx.ext.intersphinx",
    "sphinx.ext.mathjax",
    "sphinx_immaterial",
]

language = "en"

html_theme_options = {
    "repo_url": "https://github.com/prasad-sawantdesai/IMAS-easybuild-setup-guide",
    "repo_name": "EasyBuild Setup Guide",
        "icon": {
        "repo": "fontawesome/brands/github",
    },
    # "toc_title_is_page_title": True,
    # "globaltoc_collapse": True,
    "features": [
        # "navigation.expand",
        # "navigation.tabs",
        "navigation.sections",
        "navigation.instant",
        # "header.autohide",
        "navigation.top",
        # "navigation.tracking",
        # "search.highlight",
        # "search.share",
        # "toc.integrate",
        # "toc.follow",
        "toc.sticky",
        # "content.tabs.link",
        "announce.dismiss",
    ],
    "palette": [
        {
            "media": "(prefers-color-scheme: light)",
            "scheme": "default",
            "primary": "blue",
            "accent": "light-green",
            "toggle": {
                "icon": "material/lightbulb-outline",
                "name": "Switch to dark mode",
            },
        },
        {
            "media": "(prefers-color-scheme: dark)",
            "scheme": "slate",
            "primary": "light-blue",
            "accent": "lime",
            "toggle": {
                "icon": "material/lightbulb",
                "name": "Switch to light mode",
            },
        },
    ],
    "globaltoc_collapse": False,
    "toc_title_is_page_title": False,
}
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

# Disable sphinx_immaterial API doc features that aren't needed
object_description_options = []

