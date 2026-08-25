import schemdraw
import schemdraw.elements as elm

with schemdraw.Drawing(show=True) as d:
    # unit=3 garante o espaçamento largo para não encavalar
    d.config(unit=3, lw=1.5, font='sans-serif')
    
    # ==========================================
    # 1. Amplificador Não-Inversor (Ganho K)
    # ==========================================
    d += elm.Dot().label('$V_{erro}$', 'left')
    op_k = d.add(elm.Opamp(sign=False).anchor('in2'))
    
    # Malha de realimentação (Ra para o terra, Rb para a saída)
    d += elm.Line().down().at(op_k.in1).length(1.5)
    pt_k = d.add(elm.Dot())
    
    d += elm.Resistor().down().label('$R_a$')
    d += elm.Ground()
    
    d += elm.Resistor().right().at(pt_k.center).tox(op_k.out).label('$R_b$')
    d += elm.Line().up().toy(op_k.out)

    # ==========================================
    # 2. Filtro RC
    # ==========================================
    d += elm.Line().right().at(op_k.out).length(0.5)
    d += elm.Resistor().label('$R_{rc}$')
    
    pt_rc = d.add(elm.Dot())
    d += elm.Capacitor().down().at(pt_rc.center).label('$C_{rc}$')
    d += elm.Ground()

    # ==========================================
    # 3. Buffer Isolador
    # ==========================================
    d += elm.Line().right().at(pt_rc.center).length(0.5)
    op_b = d.add(elm.Opamp(sign=False).anchor('in2'))
    
    # Realimentação direta do Buffer
    d += elm.Line().up().at(op_b.in1).length(1.5)
    d += elm.Line().right().tox(op_b.out)
    d += elm.Line().down().toy(op_b.out)

    # ==========================================
    # 4. Filtro RLC
    # ==========================================
    d += elm.Line().right().at(op_b.out).length(0.5)
    d += elm.Resistor().label('$R_{rlc}$')
    d += elm.Inductor().label('$L$')
    
    pt_out = d.add(elm.Dot())
    d += elm.Line().right().length(1).label('$V_{out}$', 'right')
    
    d += elm.Capacitor().down().at(pt_out.center).label('$C$')
    d += elm.Ground()