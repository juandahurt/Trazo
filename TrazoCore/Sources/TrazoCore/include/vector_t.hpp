//
//  vector_t.hpp
//  TrazoCore
//
//  Created by Juan Hurtado on 11/03/25.
//

#ifndef vector_t_hpp
#define vector_t_hpp

#include <iostream>

class vector_t {
public:
    float x;
    float y;
    
    vector_t(float x, float y): x(x), y(y) {}
    ~vector_t() {}
    
    vector_t operator +(const vector_t& other) const;
    vector_t operator -(const vector_t& other) const;
    vector_t operator /(float scalar) const;
    
    float distance_to(const vector_t& vector) const;
    float length() const;
};

vector_t operator *(const vector_t& vector, float scalar);
vector_t operator *(float scalar, const vector_t& vector);

#endif /* vector_t_hpp */
