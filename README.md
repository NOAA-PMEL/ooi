Legal Disclaimer
This repository is a software product and is not official communication of the National Oceanic and Atmospheric Administration (NOAA), or the United States Department of Commerce (DOC). All NOAA GitHub project code is provided on an 'as is' basis and the user assumes responsibility for its use. Any claims against the DOC or DOC bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation, or favoring by the DOC. The DOC seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by the DOC or the United States Government.

# ooi
streamed data from OOI
# data in this instrument:
# oxy_calphase practical_salinity seawater_pressure density_qc_executed
# driver_timestamp ctd_tc_oxygen_qc_executed conductivity
# seawater_pressure_qc_results ctd_tc_oxygen practical_salinity_qc_results
# temperature density seawater_temperature_qc_results pressure_temp
# internal_timestamp seawater_conductivity_qc_results
# ctd_tc_oxygen_qc_results dissolved_oxygen_qc_results
# preferred_timestamp': port_timestamp', ingestion_timestamp port_timestamp
# seawater_pressure_qc_executed pressure seawater_temperature oxygen
# dissolved_oxygen seawater_conductivity practical_salinity_qc_executed
# oxy_temp seawater_temperature_qc_executed density_qc_results time
# dissolved_oxygen_qc_executed seawater_conductivity_qc_executed

# data[0] = {
# u'oxy_calphase': -9999999, 
# u'practical_salinity': 34.51587086006168, 
# u'seawater_pressure': 1559.7261669602206, 
# u'density_qc_executed': 1, 
# u'driver_timestamp': 3745594521.770782, 
# u'ctd_tc_oxygen_qc_executed': 1, 
# u'conductivity': 1488358, 
# u'seawater_pressure_qc_results': 1, 
# u'ctd_tc_oxygen': -1009.9999, 
# u'practical_salinity_qc_results': 1, 
# u'temperature': 532116, 
# u'density': 1034.778887900451, 
# u'seawater_temperature_qc_results': 1, 
# u'pressure_temp': 12716, 
# u'internal_timestamp': 0.0, 
# u'seawater_conductivity_qc_results': 1, 
# u'pk': {
# u'node': 
# u'MJ03B', 
# u'stream': 
# u'ctdpf_optode_sample', 
# u'subsite': 
# u'RS03ASHS', 
# u'deployment': 4, 
# u'time': 3745594521.6167817, 
# u'sensor': 
# u'10-CTDPFB304', 
# u'method': 
# u'streamed'}, 
# u'ctd_tc_oxygen_qc_results': 0, 
# u'dissolved_oxygen_qc_results': 0, 
# u'preferred_timestamp': 
# u'port_timestamp', 
# u'ingestion_timestamp': 3745605883.31, 
# u'port_timestamp': 3745594521.6167817, 
# u'seawater_pressure_qc_executed': 1, 
# u'pressure': 782158, 
# u'seawater_temperature': 2.4267815572215454, 
# u'oxygen': -9999999, 
# u'dissolved_oxygen': -816.7194908028131, 
# u'seawater_conductivity': 3.1444262107656735, 
# u'practical_salinity_qc_executed': 1, 
# u'oxy_temp': -9999999, 
# u'seawater_temperature_qc_executed': 1, 
# u'density_qc_results': 1, 
# u'time': 3745594521.6167817, 
# u'dissolved_oxygen_qc_executed': 1, 
# u'seawater_conductivity_qc_executed': 1}

>>> dir (response)
['__attrs__', '__bool__', '__class__', '__delattr__', '__dict__', '__doc__', '__enter__', '__exit__', '__format__', '__getattribute__', '__getstate__', '__hash__', '__init__', '__iter__', '__module__', '__new__', '__nonzero__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__setstate__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', '_content', '_content_consumed', '_next', 'apparent_encoding', 'close', 'connection', 'content', 'cookies', 'elapsed', 'encoding', 'headers', 'history', 'is_permanent_redirect', 'is_redirect', 'iter_content', 'iter_lines', 'json', 'links', 'next', 'ok', 'raise_for_status', 'raw', 'reason', 'request', 'status_code', 'text', 'url']

Fri Nov  9 15:34:48 PST 2018
 ./oo.py 2018-11-06+00.00
=== 2018-11-06+00.00
code 502, reason Bad Gateway
https://ooinet.oceanobservatories.org/api/m2m/12576/sensor/inv/RS03ASHS/MJ03B/10-CTDPFB304/streamed/ctdpf_optode_sample?beginDT=2018-11-06T00%3A00%3A00.000Z&endDT=2018-11-06T00%3A15%3A00.000Z&limit=3600
./oo.py fail: request error 502
Traceback (most recent call last):
  File "./oo.py", line 126, in <module>
    data = dataSegment( url=dataRequestUrl, params=params, auth=auth )
  File "./oo.py", line 65, in dataSegment
    raise ValueError(('request error %s' % response.status_code, response))
ValueError: ('request error 502', <Response [502]>)

