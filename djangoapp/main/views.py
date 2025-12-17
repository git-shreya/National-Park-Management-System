from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.http import HttpResponseForbidden
from django.contrib.auth import logout
from django.db import connection
from .models import Staff, Animal, Species, Habitat, Ticket, Visitor, TourPackage, Zone, Enclosure
from .forms import TicketForm, StaffForm
from datetime import date
# -------------------------
# Visitor pages
# -------------------------
def visitor_home(request):
 
    animals = list(Animal.objects.all()[:6])

    # Fixed images for each animal - MAKE SURE THESE MATCH YOUR ANIMAL NAMES
    image_map = {
        "Simba": "https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=800",  # Lion
        "Ollie": "https://www.shutterstock.com/image-photo/asian-smallclawed-otter-known-oriental-600nw-2545044935.jpg",  # Otter
        "Ella": "https://images.unsplash.com/photo-1564760055775-d63b17a55c44?w=800",  # Elephant
        "Kiko": "https://images.pexels.com/photos/326900/pexels-photo-326900.jpeg?cs=srgb&dl=pexels-pixabay-326900.jpg&fm=jpg",  # Bird/Macaw
        "Coco": "https://images.pexels.com/photos/2678483/pexels-photo-2678483.jpeg",  # Monkey
    }

    # Attach each animal its own image - with a proper fallback for animals
    for a in animals:
        a.image_url = image_map.get(
            a.animal_name,
            "https://images.unsplash.com/photo-1474511320723-9a56873867b5?w=800"  # Generic animal fallback
        )

    return render(request, "main/visitor_home.html", {"animals": animals})

def gallery(request):
    
    animals = [
    {"name": "Lion", "image": "lion1.jpg", "species": "Panthera leo"},
    {"name": "Kingfisher", "image": "kingfisher.jpg", "species": "Alcedinidae"},
    {"name": "Elephant", "image": "elephant1.jpeg", "species": "Loxodonta"},
    {"name": "Macaw", "image": "macaw1.jpeg", "species": "Ara"},
    {"name": "Otter", "image": "otter1.jpg", "species": "Lutrinae"},
    {"name": "Tiger", "image": "tiger.jpg", "species": "Panthera tigris"},
    {"name": "Leopard", "image": "leopard.jpg", "species": "Panthera pardus"},
    {"name": "Bear", "image": "bear.jpg", "species": "Ursidae"},
    {"name": "Deer", "image": "deer.jpg", "species": "Cervidae"},
    {"name": "Hippopotamus", "image": "hippo.jpeg", "species": "Hippopotamus amphibius"},
    {"name": "Giraffe", "image": "giraffe.jpeg", "species": "Giraffa"},
]

    return render(request, "main/gallery.html", {"animals": animals})


def ticket_booking(request):
    packages = TourPackage.objects.all()

    if request.method == "POST":
        name = request.POST.get("visitor_name")
        contact = request.POST.get("contact_no")
        visit_date = request.POST.get("visit_date")
        payment_mode = "Online"
        ticket_type = "Normal"
        visitor_count = int(request.POST.get("visitor_count", 1))
        if visitor_count < 1 or visitor_count > 5:
            messages.error(request, "You can book a ticket for 1 to 5 visitors only.")
            return redirect("ticket_booking")

        package_id = request.POST.get("package")

        with connection.cursor() as cursor:
            cursor.callproc(
                "RegisterVisitorAndTicket",
                [name, contact, visit_date, payment_mode,
                 ticket_type, visitor_count, package_id]
            )

            # Now fetch the LAST ticket inserted
            cursor.execute("SELECT MAX(ticket_id) FROM Ticket")
            new_ticket_id = cursor.fetchone()[0]

        # Save to session
        request.session["last_ticket_id"] = new_ticket_id

        return redirect("ticket_confirmation")

    return render(request, "main/ticket_booking.html", {
        "packages": packages,
        "today": date.today().isoformat()  # Add this line
    })
def ticket_confirmation(request):
    ticket_id = request.session.get("last_ticket_id")

    if not ticket_id:
        return render(request, "main/ticket_confirmation.html", {
            "error": "No ticket found in session."
        })

    ticket = Ticket.objects.select_related("visitor", "package").get(ticket_id=ticket_id)

    return render(request, "main/ticket_confirmation.html", {"ticket": ticket})

def ticket_list(request):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    tickets = Ticket.objects.select_related('visitor', 'package').all().order_by('-visit_date')
    return render(request, "main/ticket_list.html", {"tickets": tickets})

# -------------------------
# Staff login/logout (session-based)
# -------------------------
def staff_login(request):
    if request.method == "POST":
        staff_id = request.POST.get("staff_id")
        password = request.POST.get("password")
        try:
            staff = Staff.objects.get(staff_id=staff_id, password=password)
            request.session["staff_id"] = staff.staff_id
            request.session["staff_name"] = staff.staff_name
            request.session['staff_role'] = staff.staff_role

            return redirect("admin_dashboard")
        except Staff.DoesNotExist:
            messages.error(request, "Invalid Staff ID or Password")
    return render(request, "main/staff_login.html")

def staff_logout(request):
    request.session.flush()
    logout(request)
    return redirect("staff_login")

# -------------------------
# Admin dashboard and CRUD
# -------------------------
def admin_dashboard(request):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    context = {
        "animal_count": Animal.objects.count(),
        "species_count": Species.objects.count(),
        "habitat_count": Habitat.objects.count(),
        "staff_count": Staff.objects.count(),
        "ticket_count": Ticket.objects.count(),
    }
    return render(request, "main/admin/admin_dashboard.html", context)

def staff_list(request):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    staff_members = Staff.objects.all()
    return render(request, "main/admin/staff_list.html", {"staff": staff_members})

def staff_add(request):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    if request.session.get("staff_role") != "Supervisor":
        return HttpResponseForbidden("Only supervisors can add staff.")
    if request.method == "POST":
        form = StaffForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect("staff_list")
    else:
        form = StaffForm()
    return render(request, "main/admin/staff_form.html", {"form": form, "title": "Add Staff"})

def staff_edit(request, staff_id):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    if request.session.get("staff_role") != "Supervisor":
        return HttpResponseForbidden("Only supervisors can edit Staff Details.")
    staff = get_object_or_404(Staff, staff_id=staff_id)
    if request.method == "POST":
        form = StaffForm(request.POST, instance=staff)
        if form.is_valid():
            form.save()
            return redirect("staff_list")
    else:
        form = StaffForm(instance=staff)
    return render(request, "main/admin/staff_form.html", {"form": form, "title": "Edit Staff"})

def staff_delete(request, staff_id):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    if request.session.get("staff_role") != "Supervisor":
        return HttpResponseForbidden("Unauthorised Action")
    staff = get_object_or_404(Staff, staff_id=staff_id)
    staff.delete()
    return redirect("staff_list")

# Zones / habitats / enclosures
def zone_list(request):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    zones = Zone.objects.all()
    return render(request, "main/zone_list.html", {"zones": zones})

def habitat_list(request):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    habitats = Habitat.objects.select_related().all()
    return render(request, "main/habitat_list.html", {"habitats": habitats})

def enclosure_list(request):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    enclosures = Enclosure.objects.select_related().all()
    return render(request, "main/enclosure_list.html", {"enclosures": enclosures})

# Visitors & tickets admin lists
def visitor_list(request):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    visitors = Visitor.objects.all()
    return render(request, "main/visitor_list.html", {"visitors": visitors})

def ticket_list(request):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    tickets = Ticket.objects.all()
    return render(request, "main/ticket_list.html", {"tickets": tickets})

# Packages (minimal)
def package_list(request):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    packages = TourPackage.objects.all()
    return render(request, "main/package_list.html", {"packages": packages})

def package_edit(request, pk):
    if "staff_id" not in request.session:
        return redirect("staff_login")
    package = get_object_or_404(TourPackage, package_id=pk)
    if request.method == "POST":
        package.package_name = request.POST.get("package_name")
        package.price = request.POST.get("price")
        package.duration = request.POST.get("duration")
        package.save()
        return redirect("package_list")
    return render(request, "main/package_edit.html", {"package": package})
