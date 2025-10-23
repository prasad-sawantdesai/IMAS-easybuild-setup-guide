import datetime

project = "IMAS EasyBuild Setup Guide"
copyright = f"{datetime.datetime.now().year}, ITER Organization"
author = "ITER Organization"
extensions = ["sphinx.ext.autosectionlabel"]
html_theme = "sphinx_immaterial"
html_title = project
html_theme_options = {
    "repo_url": "https://github.com/prasad-sawantdesai/IMAS-easybuild-setup-guide",
    "repo_name": "EasyBuild Setup Guide",
    "icon": {
        "repo": "fontawesome/brands/github",
    },
    "font": False,  # Disable Google Fonts to avoid the extension error
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
    # "toc_title_is_page_title": True,
    # "globaltoc_collapse": True,
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
    "version_dropdown": True,
    "version_json": "../versions.js",
}
