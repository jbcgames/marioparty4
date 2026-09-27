import os, sys

pid = sys.argv[1] if len(sys.argv) > 1 else "32459"
try:
    for t in os.listdir(f"/proc/{pid}/task"):
        try:
            with open(f"/proc/{pid}/task/{t}/stat") as f:
                fields = f.read().split()
                pc = hex(int(fields[29]))
                sp = hex(int(fields[28]))
                comm = fields[1]
                print(f"TID {t} ({comm}): PC={pc} SP={sp}")
        except Exception:
            pass
except Exception as e:
    print("Error:", e)
