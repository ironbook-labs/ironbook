from django.conf import settings
from django.contrib import admin
from django.contrib.staticfiles.storage import staticfiles_storage
from django.urls import include, path, re_path
from django.views.generic import TemplateView
from django.views.generic.base import RedirectView

from ironbook import views


class FaviconRedirectView(RedirectView):
    permanent = True

    def get_redirect_url(self, *args, **kwargs):
        # Resolve at request time: staticfiles_storage.url() raises
        # "Missing staticfiles manifest entry" at import time when
        # collectstatic has not run yet (e.g. during `tailwind build`
        # in the Docker image build), which breaks every manage.py
        # command on a fresh checkout.
        return staticfiles_storage.url("img/favicon.png")


urlpatterns = [
    re_path(
        r"^favicon\.ico$",
        FaviconRedirectView.as_view(),
    ),
    path(
        "robots.txt",
        TemplateView.as_view(template_name="robots.txt", content_type="text/plain"),
    ),
    path("admin/", admin.site.urls),
    path("web/", include("web.urls")),
    path("", views.redirect_to_web),
    path("health_check/", views.health_check, name="health_check"),
]

if settings.DEBUG:
    # Include django browser reload URLs only in debug mode
    urlpatterns += [
        path("__reload__/", include("django_browser_reload.urls")),
    ]
