from django.urls import path
from . import views

urlpatterns = [
    # Visitor
    path('', views.visitor_home, name='visitor_home'),
    path('gallery/', views.gallery, name='gallery'),
    path('ticket-booking/', views.ticket_booking, name='ticket_booking'),
    path('ticket-confirmation/', views.ticket_confirmation, name='ticket_confirmation'),

    # Staff auth
    path('staff/login/', views.staff_login, name='staff_login'),
    path('staff/logout/', views.staff_logout, name='staff_logout'),

    # Admin
    path('admin/admin_dashboard/', views.admin_dashboard, name='admin_dashboard'),

    # Staff CRUD
    path('admin/staff/', views.staff_list, name='staff_list'),
    path('admin/staff/add/', views.staff_add, name='staff_add'),
    path('admin/staff/<int:staff_id>/edit/', views.staff_edit, name='staff_edit'),
    path('admin/staff/<int:staff_id>/delete/', views.staff_delete, name='staff_delete'),

    # Zones/habitats/enclosures
    path('admin/zones/', views.zone_list, name='zone_list'),
    path('admin/habitats/', views.habitat_list, name='habitat_list'),
    path('admin/enclosures/', views.enclosure_list, name='enclosure_list'),

    # Visitors & tickets admin
    path('admin/visitors/', views.visitor_list, name='visitor_list'),
    path('admin/tickets/', views.ticket_list, name='ticket_list'),
    path('admin/tickets/', views.ticket_list, name='ticket_list'),

    # Packages
    path('admin/packages/', views.package_list, name='package_list'),
    path('admin/packages/edit/<int:pk>/', views.package_edit, name='package_edit'),
]
