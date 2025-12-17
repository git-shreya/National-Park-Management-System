from django import forms
from .models import Ticket, Staff

class TicketForm(forms.ModelForm):
    class Meta:
        model = Ticket
        fields = [
            # field names based on models.py above
            "visit_date", "payment_mode", "ticket_type", "visitor_count", "package"
        ]
        widgets = {
            "visit_date": forms.DateInput(attrs={"type": "date"})
        }

class StaffForm(forms.ModelForm):
    class Meta:
        model = Staff
        fields = ["staff_id", "staff_name", "staff_role", "salary", "sup", "password"]
        widgets = {
            "password": forms.PasswordInput(render_value=True)
        }
