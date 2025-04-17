class macross:
    """ Create attribute properties for tracking and launching MACROSS tools.
    """
    def __init__(self,name,access,priv,valtype,lang,author,evalmax,rtype,ver,fname):
        self.name = name
        self.access = access
        self.priv = priv
        self.valtype = valtype
        self.lang = lang
        self.author = author
        self.evalmax = evalmax
        self.rtype = rtype
        self.ver = ver
        self.fname = fname

    def __str__(self):
        atts: dict = {
            "Name":self.name,
            "Access":self.access,
            "Privilege":self.priv,
            "Evaluates":self.valtype,
            "Language":self.lang,
            "Author":self.author,
            "Max Args":self.evalmax,
            "Response":self.rtype,
            "Version":self.ver,
            "Fullname":self.fname
        }
        attrs: list = []
        labels: int = len(max(atts.keys(),key=len))
        for A in atts.keys():
            attrs.append(f"{A: <{labels}}: {atts[A]}")
        return "\n".join(attrs)
    
    def __repr__(self):
        return_string: list = [
            f"name={self.name}",
            f"access={self.access}",
            f"priv={self.priv}",
            f"valtype={self.valtype}",
            f"lang={self.lang}",
            f"author={self.author}",
            f"evalmax={self.evalmax}",
            f"rtype={self.rtype}",
            f"ver={self.ver}",
            f"fname={self.fname}"
        ]
        return f"macross({', '.join(return_string)})"
