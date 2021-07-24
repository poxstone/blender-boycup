import bpy


scene = bpy.context.scene
scene.cycles.device = 'GPU'

prefs = bpy.context.preferences
cprefs = prefs.addons['cycles'].preferences

# load devices (GPUS) in PC
cprefs.get_devices()

#for compute_device_type in ('NONE','OPENCL','CUDA'):
try:
    cprefs.compute_device_type = 'CUDA'
except TypeError:
    pass

print("DEBUG: cprefs.compute_device_type= " + str(cprefs.compute_device_type))
# Enable all CPU and GPU devices
print("DEBUG: cprefs.devices= " + str(cprefs.devices))
for device in cprefs.devices:
    device.use = True
    print("DEBUG: device.use= " + str(device.use))


for i in bpy.data.objects:
    print(">->->" + i.name_full)

# Set active camera
bpy.context.scene.camera = bpy.data.objects["Camera"]
