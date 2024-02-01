from rest_framework import viewsets
from apidemo.serializers import EmployeeSerializer, DepartmentSerializer
from apidemo.models import Employee,Department
# Create your views here.



class EmployeeViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides 'CRUD' actions.
    """
    queryset = Employee.objects.all()
    serializer_class = EmployeeSerializer



class DeptViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides 'CRUD' actions.
    """
    queryset = Department.objects.all()
    serializer_class = DepartmentSerializer