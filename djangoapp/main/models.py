# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class Animal(models.Model):
    animal_id = models.IntegerField(primary_key=True)
    animal_name = models.CharField(max_length=120)
    gender = models.CharField(max_length=1, blank=True, null=True)
    health_status = models.CharField(max_length=100, blank=True, null=True)
    dob = models.DateField(db_column='DOB', blank=True, null=True)  # Field name made lowercase.
    enclosure = models.ForeignKey('Enclosure', models.DO_NOTHING, blank=True, null=True)
    species = models.ForeignKey('Species', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'animal'


class Caretaker(models.Model):
    staff = models.OneToOneField('Staff', models.DO_NOTHING, primary_key=True)
    assigned_area = models.CharField(max_length=150, blank=True, null=True)
    shift_timing = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'caretaker'


class Enclosure(models.Model):
    enclosure_id = models.IntegerField(primary_key=True)
    habitat = models.ForeignKey('Habitat', models.DO_NOTHING)
    enclosure_name = models.CharField(max_length=150)

    class Meta:
        managed = False
        db_table = 'enclosure'


class EnclosureCaretaker(models.Model):
    staff = models.ForeignKey(Caretaker, models.DO_NOTHING)
    enclosure = models.ForeignKey(Enclosure, models.DO_NOTHING)
    assigned_from = models.DateField(blank=True, null=True)
    assigned_to = models.DateField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'enclosure_caretaker'
        unique_together = (('staff', 'enclosure'),)


class Guide(models.Model):
    staff = models.OneToOneField('Staff', models.DO_NOTHING, primary_key=True)
    guide_rating = models.DecimalField(max_digits=3, decimal_places=2, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'guide'


class Habitat(models.Model):
    habitat_id = models.IntegerField(primary_key=True)
    habitat_name = models.CharField(max_length=150)
    zone = models.ForeignKey('Zone', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'habitat'


class PackageZones(models.Model):
    package = models.ForeignKey('TourPackage', models.DO_NOTHING)
    zone = models.ForeignKey('Zone', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'package_zones'
        unique_together = (('package', 'zone'),)


class Species(models.Model):
    species_id = models.IntegerField(primary_key=True)
    scientificname = models.CharField(max_length=200)
    cons_status = models.CharField(max_length=100, blank=True, null=True)
    common_name = models.CharField(max_length=150, blank=True, null=True)
    primary_diet_type = models.CharField(max_length=100, blank=True, null=True)
    avg_lifespan = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'species'


class Staff(models.Model):
    staff_id = models.IntegerField(primary_key=True)
    staff_name = models.CharField(max_length=100)
    salary = models.DecimalField(max_digits=12, decimal_places=2, blank=True, null=True)
    staff_role = models.CharField(max_length=50)
    sup = models.ForeignKey('self', models.DO_NOTHING, blank=True, null=True)
    password = models.CharField(max_length=128, default='')

    class Meta:
        managed = False
        db_table = 'staff'


class StaffContact(models.Model):
    contact_id = models.IntegerField(primary_key=True)
    staff = models.ForeignKey(Staff, models.DO_NOTHING)
    contact = models.CharField(max_length=50)
    contact_type = models.CharField(max_length=30, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'staff_contact'


class Supervisor(models.Model):
    staff = models.OneToOneField(Staff, models.DO_NOTHING, primary_key=True)
    years_of_exp = models.IntegerField(blank=True, null=True)
    grade_level = models.CharField(max_length=50, blank=True, null=True)
    area_of_supervision = models.CharField(max_length=150, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'supervisor'


class Ticket(models.Model):
    ticket_id = models.IntegerField(primary_key=True)
    visitor = models.ForeignKey('Visitor', models.DO_NOTHING)
    visit_date = models.DateField()
    payment_mode = models.CharField(max_length=50, blank=True, null=True)
    ticket_type = models.CharField(max_length=50, blank=True, null=True)
    visitor_count = models.IntegerField(blank=True, null=True)
    package = models.ForeignKey('TourPackage', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ticket'


class TicketLog(models.Model):
    log_id = models.AutoField(primary_key=True)
    ticket_id = models.IntegerField(blank=True, null=True)
    package_id = models.IntegerField(blank=True, null=True)
    visit_date = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ticket_log'


class TourPackage(models.Model):
    package_id = models.IntegerField(primary_key=True)
    package_name = models.CharField(max_length=150)
    duration = models.IntegerField(blank=True, null=True)
    guide = models.ForeignKey(Guide, models.DO_NOTHING, blank=True, null=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    sup = models.ForeignKey(Supervisor, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'tour_package'


class TouristFacilities(models.Model):
    facility_id = models.IntegerField(primary_key=True)
    zone = models.ForeignKey('Zone', models.DO_NOTHING)
    facility_type = models.CharField(max_length=100)
    operating_hours = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'tourist_facilities'


class TouristStaff(models.Model):
    pk = models.CompositePrimaryKey('staff_id', 'facility_id')
    staff = models.ForeignKey(Staff, models.DO_NOTHING)
    facility = models.ForeignKey(TouristFacilities, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'tourist_staff'


class Visitor(models.Model):
    visitor_id = models.AutoField(primary_key=True)
    visitor_name = models.CharField(max_length=100)
    contact_no = models.CharField(max_length=20)


    class Meta:
        managed = False
        db_table = 'visitor'


class Zone(models.Model):
    zone_id = models.IntegerField(primary_key=True)
    zone_name = models.CharField(max_length=100)
    sup = models.ForeignKey(Supervisor, models.DO_NOTHING, blank=True, null=True)
    habitat_type = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'zone'
