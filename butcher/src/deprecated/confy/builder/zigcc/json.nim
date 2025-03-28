proc yesterday (trg :Path= cfg.zigJson) :bool=  Fil(trg).noModSince(hours = 24)
  ## Returns true if the json file hasn't been updated in the last 24h.

