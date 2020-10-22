function e --description 'Opens file using Emacs'
    emacsclient -a 'emacs' -n "$argv" 2>/dev/null || command emacs
end
