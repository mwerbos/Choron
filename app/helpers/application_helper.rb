module ApplicationHelper
    def bid_sorter(a,b)
        return 2*(a.amount <=> b.amount)+(a.created_at <=> b.created_at)
    end
end
