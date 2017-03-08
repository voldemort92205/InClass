clear
close

% author : r05229011

% write a 6*6 Hilbert matrix

n = 6;
h = zeros (n, n);

for i = 1:n
	for j = 1:n
		h(i, j) = 1 / (i+j-1);
	end
end

format rat
h
format short
