from django.conf import settings
from django.contrib import admin
from django.contrib.staticfiles.storage import staticfiles_storage
from django.shortcuts import redirect
from django.urls import include, path, re_path
from django.views.generic import TemplateView

from ironbook import views


def favicon(request):
    return redirect(staticfiles_storage.url("img/favicon.png"), permanent=True)


urlpatterns = [
    re_path(r"^favicon\.ico$", favicon),
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
