from rest_framework import viewsets, filters
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from apidemo.serializers import EmployeeSerializer, DepartmentSerializer
from apidemo.models import Employee,Department
# Create your views here.



class EmployeeViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows employees to be viewed or edited.
    Supports filtering, searching, ordering, and pagination.
    """
    queryset = Employee.objects.all()
    serializer_class = EmployeeSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["first_name", "last_name", "department__title"]
    ordering_fields = ["first_name", "last_name", "birthdate", "department__title"]
    permission_classes = [IsAuthenticatedOrReadOnly]



class DeptViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows departments to be viewed or edited.
    Supports searching, ordering, and pagination.
    """
    queryset = Department.objects.all()
    serializer_class = DepartmentSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["title"]
    ordering_fields = ["title"]
    permission_classes = [IsAuthenticatedOrReadOnly]