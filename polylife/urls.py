"""URL configuration for the PolyLife project.

The core only serves auth, admin and the SPA. Team services run as separate
containers behind the shared gateway (see ``deploy/``); the one exception is a
container that deliberately runs this project with ``TEAM_APPS`` set (team 6),
in which case that app's routes are mounted as well.
"""

from django.conf import settings
from django.contrib import admin
from django.urls import include, path, re_path

from core.views import home


urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include("core.urls")),
]

if "teams.team6" in settings.TEAM_APPS:
    urlpatterns.append(path("api/", include("teams.team6.urls")))

# Catch-all: serve the SPA (and its client-side routes). Must stay last.
urlpatterns.append(re_path(r"^.*$", home, name="home"))
