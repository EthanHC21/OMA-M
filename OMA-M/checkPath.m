function newPath = checkPath(p)

if (p(length(p)) == '\')
    newPath = p;
else
    p(length(p) + 1) = '\';
    newPath = p;
end

end